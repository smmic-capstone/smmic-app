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
import 'package:web_socket_channel/web_socket_channel.dart';

class DevicesProvider extends ChangeNotifier {
  // dependencies
  final Logs _logs = Logs(tag: 'DevicesProvider()');
  final DevicesServices _devicesServices = DevicesServices();
  final DeviceUtils _deviceUtils = DeviceUtils();
  final SharedPrefsUtils _sharedPrefsUtils = SharedPrefsUtils();

  // api helpers, dependencies
  final ApiRoutes _apiRoutes = ApiRoutes();
  final ApiRequest _apiRequest = ApiRequest();

  // sink node map lists
  Map<String, SinkNode> _sinkNodeMap = {}; // ignore: prefer_final_fields
  Map<String, SinkNode> get sinkNodeMap => _sinkNodeMap;
  // sensor node
  Map<String, SensorNode> _sensorNodeMap = {}; // ignore: prefer_final_fields
  Map<String, SensorNode> get sensorNodeMap => _sensorNodeMap;

  // sensor node readings map
  Map<String, SensorNodeSnapshot> _sensorNodeSnapshotMap = {}; // ignore: prefer_final_fields
  Map<String, SensorNodeSnapshot> get sensorNodeSnapshotMap => _sensorNodeSnapshotMap;

  // sensor node chart data map
  Map<String, List<SensorNodeSnapshot>> _sensorNodeChartDataMap = {}; // ignore: prefer_final_fields
  Map<String, List<SensorNodeSnapshot>> get sensorNodeChartDataMap => _sensorNodeChartDataMap;

  // sm alerts
  List<SMAlerts?> _smAlertsList = []; // ignore: prefer_final_fields
  List<SMAlerts?> get smAlertsList => _smAlertsList;

  SMAlerts? _alertCode;
  SMAlerts? get alertCode => _alertCode;

  SMAlerts? _humidityAlert;
  SMAlerts? _tempAlert;
  SMAlerts? _moistureAlert;

  SMAlerts? get humidityAlert => _humidityAlert;
  SMAlerts? get tempAlert => _tempAlert;
  SMAlerts? get moistureAlert => _moistureAlert;

  Map <String, Map<String,int>> _deviceAlerts = {};

  Future<void> init({
    required ConnectivityResult connectivity}) async {
    _logs.info(message: 'init() running');

    // acquire user data and tokens from shared prefs
    Map<String, dynamic>? userData = await _sharedPrefsUtils.getUserData();
    Map<String, dynamic> tokens = await _sharedPrefsUtils.getTokens(access: true);

    if (userData == null) {
      _logs.warning(message: '.init() -> user data null!');
      return;
    }

    await _setDeviceListFromApi(userData: userData, tokens: tokens);
    notifyListeners();
  }

  // set device list with data from the api
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

        SensorNodeSnapshot? fromSQFLiteSnapshot = await DatabaseHelper.getAllReadings(sensor.deviceID);
        if (fromSQFLiteSnapshot != null){
          _sensorNodeSnapshotMap[sensor.deviceID] = fromSQFLiteSnapshot;
        }
        List<SensorNodeSnapshot>? fromSQFLiteChartData = await DatabaseHelper.chartReadings(sensor.deviceID);
        if (fromSQFLiteChartData != null) {
          _sensorNodeChartDataMap[sensor.deviceID] = fromSQFLiteChartData;
        }
      }
    }

    notifyListeners();
    return true;
  }

  Future<void> _setDeviceListFromSharedPrefs() async {
    List<Map<String, dynamic>> sinkList = await _sharedPrefsUtils.getSinkList();
    List<Map<String, dynamic>> sensorList = await _sharedPrefsUtils.getSensorList();

    for (Map<String, dynamic> sinkMap in sinkList) {
      SinkNode sinkObj = _deviceUtils.sinkNodeMapToObject(sinkMap);
      _sinkNodeMap[sinkObj.deviceID] = sinkObj;
    }
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
  void setNewSensorSnapshot(var reading) {
    SensorNodeSnapshot? finalSnapshot;

    if (reading is Map<String, dynamic>) {
      // TODO: verify keys first
      finalSnapshot = SensorNodeSnapshot.fromJSON(reading);
    } else if (reading is String) {
      // assuming that if the reading variable is a string, it is an mqtt payload
      Map<String, dynamic> fromStringMap = {};
      List<String> outerSplit = reading.split(';');

      fromStringMap.addAll({
        'device_id': outerSplit[1],
        'timestamp': outerSplit[2],
      });

      List<String> dataSplit = outerSplit[3].split('&');

      for (String keyValue in dataSplit) {
        try {
          List<String> x = keyValue.split(':');
          fromStringMap.addAll({x[0]: x[1]});
        } on FormatException catch (e) {
          _logs.error(message: 'setNewSensorReadings() raised FormatException error -> $e}');
          break;
        }
      }

      // create a new sensor node snapshot object from the new string map
      finalSnapshot = SensorNodeSnapshot.fromJSON(fromStringMap);

    } else if (reading is SensorNodeSnapshot) {
      finalSnapshot = reading;
    }

    if (finalSnapshot == null) {
      return;
    }

    // set snapshot
    _sensorNodeSnapshotMap[finalSnapshot.deviceID] = finalSnapshot;
    // set chartdata
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

  Future<void> deviceReadings(String deviceID) async {
    _logs.info(message: 'deviceReadings running');

    final latestReading = await DatabaseHelper.getAllReadings(deviceID);

    if (latestReading == null) {
      return;
    }

    _sensorNodeSnapshotMap[latestReading.deviceID] = latestReading;
    notifyListeners();
  }

  Future<void> sensorNodeAlerts ({required SMAlerts alertMessage}) async {
    _logs.info(message: "sensorNodeAlerts running");

    List<Map<String, dynamic>>? alertDataSharedPrefs = await _sharedPrefsUtils.getAlertsData();
    alertDataSharedPrefs ??= [];

    alertDataSharedPrefs.removeWhere((alert) {
      return alert['device_id'] == alertMessage.deviceID &&
          (int.parse(alert['alerts']) ~/ 10) == (alertMessage.alerts ~/ 10);
    });

    alertDataSharedPrefs.add(alertMessage.toJson());

    _logs.info(message: "alertMessage : ${alertMessage.deviceID}");
    _logs.info(message: "alertDataSharedPrefs : $alertDataSharedPrefs");

    _sharedPrefsUtils.setAlertsData(alertsList: alertDataSharedPrefs);

    _logs.info(message: "sensorNodeAlerts Running");

    _alertCode = alertMessage;

    if(alertMessage.alerts >= 20 && alertMessage.alerts < 30){
      _humidityAlert =  alertMessage;
    }else if(alertMessage.alerts >= 30 && alertMessage.alerts < 40){
      _tempAlert = alertCode;
    }else if(alertMessage.alerts >= 40 && alertMessage.alerts < 50){
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