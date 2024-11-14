import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smmic/constants/api.dart';
import 'package:smmic/models/device_data_models.dart';
import 'package:smmic/services/devices_services.dart';
import 'package:smmic/sqlitedb/db.dart';
import 'package:smmic/utils/api.dart';
import 'package:smmic/utils/device_utils.dart';
import 'package:smmic/utils/logs.dart';
import 'package:smmic/utils/shared_prefs.dart';

class DevicesProvider extends ChangeNotifier {
  // dependencies
  final Logs _logs = Logs(tag: 'DevicesProvider()');
  final DevicesServices _devicesServices = DevicesServices();
  final DeviceUtils _deviceUtils = DeviceUtils();
  final SharedPrefsUtils _sharedPrefsUtils = SharedPrefsUtils();

  // api helpers, dependencies
  final ApiRoutes _apiRoutes = ApiRoutes();
  final ApiRequest _apiRequest = ApiRequest();

  // sink node map
  Map<String, SinkNode> _sinkNodeMap = {}; // ignore: prefer_final_fields
  Map<String, SinkNode> get sinkNodeMap => _sinkNodeMap;
  // sensor node map
  Map<String, SensorNode> _sensorNodeMap = {}; // ignore: prefer_final_fields
  Map<String, SensorNode> get sensorNodeMap => _sensorNodeMap;

  // sensor node readings map
  Map<String, SensorNodeSnapshot> _sensorNodeSnapshotMap = {}; // ignore: prefer_final_fields
  Map<String, SensorNodeSnapshot> get sensorNodeSnapshotMap => _sensorNodeSnapshotMap;

  // sensor node chart data map
  Map<String, List<SensorNodeSnapshot>> _sensorNodeChartDataMap = {}; // ignore: prefer_final_fields
  Map<String, List<SensorNodeSnapshot>> get sensorNodeChartDataMap => _sensorNodeChartDataMap;

  // sm alerts
  List<SensorAlerts?> _smAlertsList = []; // ignore: prefer_final_fields
  List<SensorAlerts?> get smAlertsList => _smAlertsList;

  SensorAlerts? _alertCode;
  SensorAlerts? get alertCode => _alertCode;

  SensorAlerts? _humidityAlert;
  SensorAlerts? _tempAlert;
  SensorAlerts? _moistureAlert;

  SensorAlerts? get humidityAlert => _humidityAlert;
  SensorAlerts? get tempAlert => _tempAlert;
  SensorAlerts? get moistureAlert => _moistureAlert;

  Map <String, Map<String,int>> _deviceAlerts = {};

  Future<void> init({required ConnectivityResult connectivity}) async {

    // set device list from the shared preferences
    // TODO: add cross checking with api to verify integrity
    await _setDeviceListFromSharedPrefs();

    // acquire user data and tokens from shared prefs
    Map<String, dynamic>? userData = await _sharedPrefsUtils.getUserData();
    Map<String, dynamic> tokens = await _sharedPrefsUtils.getTokens(access: true);

    if (userData == null) {
      _logs.warning(message: '.init() -> user data from shared prefs is null!');
      return;
    }

    // if connection sources are available,
    // attempt setting device list from the api
    if (connectivity != ConnectivityResult.none) {
      await _setDeviceListFromApi(userData: userData, tokens: tokens);
    }

    // initially, load readings from the sqlite
    await _loadReadingsFromSqlite();

    notifyListeners();

    // set *updated* list to shared preferences
    await _setToSharedPrefs();
  }

  /// Set current SinkNode and Sensor Node *objects* map
  /// to shared preferences as `List<String>`
  Future<bool> _setToSharedPrefs() async {

    List<String> sinkNodeIds = _sinkNodeMap.keys.toList();
    List<Map<String, dynamic>> sinkNodeMapList = [];
    for (String id in sinkNodeIds) {
      SinkNode skObj = _sinkNodeMap[id]!;
      Map<String, dynamic> skMap = {
        SinkNodeKeys.deviceID.key : skObj.deviceID,
        SinkNodeKeys.deviceName.key : skObj.deviceName,
        SinkNodeKeys.latitude.key : skObj.latitude,
        SinkNodeKeys.longitude.key : skObj.longitude,
        SinkNodeKeys.registeredSensorNodes.key : skObj.registeredSensorNodes
      };
      sinkNodeMapList.add(skMap);
    }
    await _sharedPrefsUtils.setSinkList(sinkList: sinkNodeMapList);

    List<String> sensorNodeIds = _sensorNodeMap.keys.toList();
    List<Map<String, dynamic>> sensorNodeMapList = [];
    for (String id in sensorNodeIds) {
      SensorNode seObj = _sensorNodeMap[id]!;
      Map<String, dynamic> seMap = {
        SensorNodeKeys.deviceID.key : seObj.deviceID,
        SensorNodeKeys.deviceName.key : seObj.deviceName,
        SensorNodeKeys.latitude.key : seObj.latitude,
        SensorNodeKeys.longitude.key : seObj.longitude,
        SensorNodeKeys.sinkNode.key : seObj.registeredSinkNode
      };
      sensorNodeMapList.add(seMap);
    }
    await _sharedPrefsUtils.setSensorList(sensorList: sensorNodeMapList);

    return true;
  }

  /// Load initial readings and chart data from the sqlite local storage
  Future<bool> _loadReadingsFromSqlite() async {
    for (String seId in _sensorNodeMap.keys) {
      SensorNodeSnapshot? fromSQFLiteSnapshot = await DatabaseHelper.getAllReadings(_sensorNodeMap[seId]!.deviceID);
      if (fromSQFLiteSnapshot != null){
        _sensorNodeSnapshotMap[_sensorNodeMap[seId]!.deviceID] = fromSQFLiteSnapshot;
      }
      List<SensorNodeSnapshot>? fromSQFLiteChartData = await DatabaseHelper.chartReadings(_sensorNodeMap[seId]!.deviceID);
      if (fromSQFLiteChartData != null) {
        _sensorNodeChartDataMap[_sensorNodeMap[seId]!.deviceID] = fromSQFLiteChartData;
      }
    }
    return true;
  }

  /// Set device list from the API
  Future<bool> _setDeviceListFromApi({
    required Map<String, dynamic> userData,
    required Map<String, dynamic> tokens}) async {

    List<Map<String, dynamic>>? devices = await _devicesServices.getDevices(
        userID: userData['UID'],
        token: tokens['access']
    );

    if (devices == null) {
      return false;
    }

    // acquire sink nodes and add to sinkNodeMap
    for (Map<String, dynamic> sinkMap in devices) {
      SinkNode sink = _deviceUtils.sinkNodeMapToObject(sinkMap);
      _sinkNodeMap[sink.deviceID] = sink;
    }

    // acquire sensor nodes and add to sensorNodeMap
    for (Map<String, dynamic> sinkMap in devices) {
      List<Map<String, dynamic>> sensorMapList = sinkMap['sensor_nodes'];
      for (Map<String, dynamic> sensorMap in sensorMapList) {
        SensorNode sensor = _deviceUtils.sensorNodeMapToObject(
            sensorMap: sensorMap,
            sinkNodeID: sinkMap['device_id']
        );
        _sensorNodeMap[sensor.deviceID] = sensor;
      }
    }

    return true;
  }

  /// Set device list from share preferences
  // TODO: add cross-checking with the API to verify integrity
  Future<bool> _setDeviceListFromSharedPrefs() async {
    List<Map<String, dynamic>> sinkList = await _sharedPrefsUtils.getSinkList();
    List<Map<String, dynamic>> sensorList = await _sharedPrefsUtils.getSensorList();

    // map sink nodes to objects and set to sink node map
    for (Map<String, dynamic> sinkMap in sinkList) {
      SinkNode sinkObj = _deviceUtils.sinkNodeMapToObject(sinkMap);
      _sinkNodeMap[sinkObj.deviceID] = sinkObj;
    }

    for (Map<String, dynamic> sensorMap in sensorList) {
      SinkNode? correspondingSk = _sinkNodeMap[sensorMap[SensorNodeKeys.sinkNode.key]];
      // check existence of corresponding sink node
      if (correspondingSk == null) {
        _logs.warning(message: 'sensor node${sensorMap[SensorNodeKeys.deviceID.key]}'
            'present in shared preferences, but corresponding SinkNode id does'
            'not exist in current _sinkNodeMap!');
        continue;
      }
      // map to object and set to sensor node map
      SensorNode sensorObj = _deviceUtils.sensorNodeMapToObject(
          sensorMap: sensorMap,
          sinkNodeID: sensorMap[SensorNodeKeys.sinkNode.key]
      );
      _sensorNodeMap[sensorObj.deviceID] = sensorObj;
    }

    return true;
  }

  // maps the payload from sensor devices
  // assuming that the shape of the payload (as a string) is:
  // ...
  // sensor_type;
  // device_id;
  // timestamp;
  // reading:value&
  // reading:value&
  // reading:value&
  // reading:value&
  // ...
  //
  /// Set a new sensor snapshot from any of the following type:
  /// `Map<String, dynamic>`, `String`, `SensorNodeSnapshot` and
  /// update chart data.
  void setNewSensorSnapshot(var reading) {
    SensorNodeSnapshot? finalSnapshot;

    finalSnapshot = SensorNodeSnapshot.dynamicSerializer(data: reading);

    if (finalSnapshot == null) {
      return;
    }

    // set snapshot
    _sensorNodeSnapshotMap[finalSnapshot.deviceID] = finalSnapshot;
    // set chart data
    List<SensorNodeSnapshot>? chartDataBuffer = _sensorNodeChartDataMap[finalSnapshot.deviceID];
    if (chartDataBuffer == null) {
      chartDataBuffer = [finalSnapshot];
    } else if (chartDataBuffer.length == 6){
      chartDataBuffer.removeAt(0);
      chartDataBuffer.add(finalSnapshot);
    } else {
      chartDataBuffer.add(finalSnapshot);
    }
    _sensorNodeChartDataMap[finalSnapshot.deviceID] = chartDataBuffer;
    notifyListeners();
    return;
  }

  Future<void> sensorNodeAlerts ({required SensorAlerts alertMessage}) async {
    _logs.info(message: "sensorNodeAlerts running");

    List<Map<String, dynamic>>? alertDataSharedPrefs = await _sharedPrefsUtils.getAlertsData();
    alertDataSharedPrefs ??= [];

    alertDataSharedPrefs.removeWhere((alert) {
      return alert['device_id'] == alertMessage.deviceID &&
          (int.parse(alert['alerts']) ~/ 10) == (alertMessage.alertCode ~/ 10);
    });

    alertDataSharedPrefs.add(alertMessage.toJson());

    _logs.info(message: "alertMessage : ${alertMessage.deviceID}");
    _logs.info(message: "alertDataSharedPrefs : $alertDataSharedPrefs");

    _sharedPrefsUtils.setAlertsData(alertsList: alertDataSharedPrefs);

    _logs.info(message: "sensorNodeAlerts Running");

    _alertCode = alertMessage;

    if(alertMessage.alertCode >= 20 && alertMessage.alertCode < 30){
      _humidityAlert =  alertMessage;
    }else if(alertMessage.alertCode >= 30 && alertMessage.alertCode < 40){
      _tempAlert = alertCode;
    }else if(alertMessage.alertCode >= 40 && alertMessage.alertCode < 50){
      _moistureAlert = alertCode;
    }

    notifyListeners();
  }

  Future<void> sinkNameChange(Map<String,dynamic> updatedSinkData) async {
    _logs.info(message: "sinkNameChange running....");

    if(_sinkNodeMap[updatedSinkData['deviceId']] == null){
      //TODO: Error Handle
      return;
    }

    _logs.info(message: "getSKList running ....");
    List<Map<String,dynamic>>? _getSKList = await _sharedPrefsUtils.getSinkList();
    _logs.info(message: "sharedPrefsUtils : ${_sharedPrefsUtils.getSinkList()}");
    _logs.info(message: "_getSKList provider : $_getSKList");
    if(_getSKList == [] || _getSKList == null){
      _logs.error(message:"Way sulod si _getSKList");
      return;
    }else{
      _logs.info(message: "updated sink data : $updatedSinkData");

      for(int i = 0; i < _getSKList.length; i++){
        _logs.info(message: "for loop getSKList: ${_getSKList[i]['deviceID'].toString()}");

        if(_getSKList[i]['deviceID'] == updatedSinkData['deviceID']){
          _logs.info(message: "Hello you have entered for loop");
          _getSKList.removeAt(i);
          _getSKList.insert(i, updatedSinkData);
        }
      }
    }
    _logs.info(message: '$_getSKList');
    bool success = await _sharedPrefsUtils.setSinkList(sinkList: _getSKList);
    if(success){
      SinkNode updatedSink = SinkNode.fromJSON(updatedSinkData);
      _sinkNodeMap[updatedSink.deviceID] = updatedSink;
      notifyListeners();
    }else{
      _logs.error(message: "Sipyat");
    }
    notifyListeners();
  }

  Future<void> sensorNameChange(Map<String,dynamic> updatedData) async {
    _logs.info(message: "sensorNameChange : $updatedData");

    if(_sensorNodeMap[updatedData['deviceID']] == null){
      ///TODO: Error Handle
      return;
    }

    List<Map<String,dynamic>>? getSNList = await _sharedPrefsUtils.getSensorList();

    if(getSNList == null || getSNList.isEmpty){
      _logs.error(message: "getSNList is empty");
      return;
    }else{
      _logs.info(message: "sensorNameChange else statement running");
      for(int i = 0; i < getSNList.length; i++){
        if(getSNList[i]['deviceID'] == updatedData['deviceID']){
          getSNList.removeAt(i);
          getSNList.insert(i, updatedData);
        }
      }
    }
    bool success = await _sharedPrefsUtils.setSensorList(sensorList: getSNList);
    if(success){
      SensorNode updatedSensor = SensorNode.fromJSON(updatedData);
      _sensorNodeMap[updatedSensor.deviceID] = updatedSensor;
      notifyListeners();
    }else{
      _logs.error(message: "err: sensor node dev provider sensorNameChange");
    }
    notifyListeners();
  }

}