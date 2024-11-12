import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  // stream controllers
  // se snapshot stream
  StreamController<SensorNodeSnapshot>? _seSnapshotStreamController;
  StreamController<SensorNodeSnapshot>? get seSnapshotStreamController => _seSnapshotStreamController;
  // alerts stream
  StreamController<SMAlerts>? _alertsStreamController;
  StreamController<SMAlerts>? get alertsStreamController => _alertsStreamController;
  // mqtt stream
  StreamController<String>? _mqttStreamController;
  StreamController<String>? get mqttStreamController => _mqttStreamController;
  
  // ws channels
  // sensor readings ws
  WebSocketChannel? _seReadingsChannel;
  WebSocketChannel? get seReadingsChannel => _seReadingsChannel;
  // alerts ws
  WebSocketChannel? _alertsChannel;
  WebSocketChannel? get alertsChannel => _alertsChannel;
  // mqtt updates channel

  // devices list
  // sink node list
  List<SinkNode> _sinkNodeList = []; // ignore: prefer_final_fields
  List<SinkNode> get sinkNodeList => _sinkNodeList;
  // sensor node list
  List<SensorNode> _sensorNodeList = [];// ignore: prefer_final_fields
  List<SensorNode> get sensorNodeList => _sensorNodeList;

  // sensor node readings
  List<SensorNodeSnapshot?> _sensorNodeSnapshotList = []; // ignore: prefer_final_fields
  List<SensorNodeSnapshot?> get sensorNodeSnapshotList => _sensorNodeSnapshotList;

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

  Future<void> init() async {
    Map<String, dynamic>? userData = await _sharedPrefsUtils.getUserData();
    Map<String, dynamic> tokens = await _sharedPrefsUtils.getTokens(access: true);

    StreamController<SensorNodeSnapshot> seSController = StreamController<SensorNodeSnapshot>.broadcast();
    StreamController<SMAlerts> alSController = StreamController<SMAlerts>.broadcast();
    StreamController<String> mqttSController = StreamController<String>.broadcast();

    WebSocketChannel? seReadingsChannel = _apiRequest.connectSeReadingsChannel(
        route: _apiRoutes.seReadingsWs,
        streamController: seSController
    );
    WebSocketChannel? alertsChannel = _apiRequest.connectAlertsChannel(
        route: _apiRoutes.seAlertsWs,
        streamController: alSController
    );

    _setStreamControllers(
        seSnapshotStreamController: seSController,
        alertsStreamController: alSController,
        mqttStreamController: mqttSController
    );
    _setWebSocketChannels(
        seReadingsChannel: seReadingsChannel,
        alertsChannel: alertsChannel
    );

    if(userData == null){
      notifyListeners();
      return;
    }

    // retrieve user devices from the api
    _logs.info(message: 'init() executing');
    List<Map<String, dynamic>>? devices = await _devicesServices.getDevices(userID: userData['UID'], token: tokens['access']);

    // map sink nodes and append items into _sinkNodeList
    //_logs.info(message: 'devices init: $devices');
    for (int i = 0; i < devices.length; i++){
      SinkNode sink = _deviceUtils.sinkNodeMapToObject(devices[i]);
      if (_sinkNodeList.isNotEmpty && _sinkNodeList.any((item) => item.deviceID == sink.deviceID)){
        continue;
      }
      _sinkNodeList.add(sink);
    }

    // map sensor nodes and append items into _sensorNodeList
    for (int i = 0; i < devices.length; i++){
      List<Map<String, dynamic>> sensorNodeList = devices[i]['sensor_nodes'];
      if (sensorNodeList.isEmpty){
        break;
      }
      for(int x = 0; x < sensorNodeList.length; x++){
        SensorNode sensor = _deviceUtils.sensorNodeMapToObject(sensorMap: sensorNodeList[x], sinkNodeID: devices[i]['device_id']);
        if (_sensorNodeList.isNotEmpty && _sensorNodeList.any((item) => item.deviceID == sensor.deviceID)) {
          continue;
        }
        _sensorNodeList.add(sensor);
      }
    }
    //_logs.info(message: "devices : $devices");

    /* _sharedPrefsUtils.setSKList(sinkList: devices);*/
    // store list of devices in the shared prefs
    List <Map<String,dynamic>> sinkNodeSharedPrefs = []; // list of sink nodes to shared prefs
    List<Map<String,dynamic>> sensorNodeSharedPrefs = []; // list of sensor nodes to shared prefs
    // the outer part of this loop iterates over the sink nodes
    for (int i = 0; i < devices.length; i++){
      Map<String,dynamic> sink = _deviceUtils.mapSinkNode(devices[i]);
      sinkNodeSharedPrefs.add(sink);
      // this inner part iterates over the sensor nodes of each sink node
      for(int j =0; j < devices[i]["sensor_nodes"].length; j++){
        Map<String,dynamic> sensor = _deviceUtils.mapSensorNode(devices[i]['sensor_nodes'][j], sink['deviceID']);

        sensorNodeSharedPrefs.add(sensor);
      }
    }

    // helper functions that finally stores the SK and SN list in the shared prefs for fast access
    _sharedPrefsUtils.setSKList(sinkList: sinkNodeSharedPrefs);
    _sharedPrefsUtils.setSNList(sensorList: sensorNodeSharedPrefs);
    //_logs.info(message: "deviceSharedPrefs data type: ${sinkNodeSharedPrefs.runtimeType}");
    /*extractSensorNodes(sensorNodeList: devices);*/


   /* for(int i=0; i < _sensorNodeList.length; i++) {
      SensorNodeSnapshot? snSnapshot = await DatabaseHelper.getAllReadings(_sensorNodeList[i].deviceID);
      _sensorNodeSnapshotList.add(snSnapshot);
      _logs.info(message: 'snSnapshot :${snSnapshot?.deviceID}');
    }*/
    //_logs.info(message: 'devices shared prefs init: $sinkNodeSharedPrefs');
    /*listenToStream();*/

    notifyListeners();
    _logs.success(message: 'init() done');
  }
  
  void _setStreamControllers({
    required seSnapshotStreamController,
    required alertsStreamController,
    required mqttStreamController}) {
    
    _seSnapshotStreamController = seSnapshotStreamController;
    _alertsStreamController = alertsStreamController;
    _mqttStreamController = mqttStreamController;
  }
  
  void _setWebSocketChannels({
    required WebSocketChannel? seReadingsChannel,
    required WebSocketChannel? alertsChannel}) {
    
    _seReadingsChannel = seReadingsChannel;
    _alertsChannel = alertsChannel;
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

    if (_sensorNodeSnapshotList.isNotEmpty) {
      List<String> snapShotListIdBuffer = _sensorNodeSnapshotList.map((item) => item!.deviceID).toList();
      if (snapShotListIdBuffer.contains(finalSnapshot.deviceID)) {
        _sensorNodeSnapshotList.removeWhere((item) => item!.deviceID == finalSnapshot!.deviceID);
      }
    }
    _sensorNodeSnapshotList.add(finalSnapshot);
    notifyListeners();
    return;
  }

  Future<void> deviceReadings(String deviceID) async {
    _logs.info(message: 'deviceReadings running');

    final latestReading = await DatabaseHelper.getAllReadings(deviceID);

    _sensorNodeSnapshotList.removeWhere((sensorNode) => sensorNode?.deviceID == deviceID);

    if (latestReading == null) {
      return;
    }

    _sensorNodeSnapshotList.add(latestReading);
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

    if(!_sinkNodeList.any((sink) => sink.deviceID == updatedSinkData['deviceID'])){
      //TODO: Error Handle
      return;
    }
    _logs.info(message: "getSKList running ....");
    List<Map<String,dynamic>>? _getSKList = await _sharedPrefsUtils.getSKList();
    _logs.info(message: "sharedPrefsUtils : ${_sharedPrefsUtils.getSKList}");
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
    bool success = await _sharedPrefsUtils.setSKList(sinkList: _getSKList);
    if(success){
      SinkNode updatedSink = SinkNode.fromJSON(updatedSinkData);
      SinkNode _oldSinkNode = _sinkNodeList.where((sink) => sink.deviceID == updatedSink.deviceID).first;
      int index = _sinkNodeList.indexOf(_oldSinkNode);
      _sinkNodeList.remove(_sinkNodeList.where((sink) => sink.deviceID == updatedSink.deviceID).first);
      _sinkNodeList.insert(index, updatedSink);
      _logs.info(message: 'provider $success');
      notifyListeners();
    }else{
      _logs.error(message: "Sipyat");
    }
    notifyListeners();
  }

  Future<void> sensorNameChange(Map<String,dynamic> updatedData) async {
    _logs.info(message: "sensorNameChange : $updatedData");
    if(!_sensorNodeList.any((sensor) => sensor.deviceID == updatedData['deviceID'])){
      ///TODO: Error Handle
      return;
    }
    List<Map<String,dynamic>>? getSNList = await _sharedPrefsUtils.getSNList();

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
    bool success = await _sharedPrefsUtils.setSNList(sensorList: getSNList);
    if(success){
      SensorNode updatedSensor = SensorNode.fromJSON(updatedData);
      SensorNode _oldSensor = _sensorNodeList.where((sensor) => sensor.deviceID == updatedSensor.deviceID).first;
      int index = _sensorNodeList.indexOf(_oldSensor);
      _sensorNodeList.remove(_sensorNodeList.where((sensor) => sensor.deviceID == updatedSensor.deviceID).first);
      _sensorNodeList.insert(index, updatedSensor);
      notifyListeners();
    }else{
      _logs.error(message: "err: sensor node dev provider sensorNameChange");
    }
    notifyListeners();
  }

  ///Extract Sensor Node
  /*void extractSensorNodes({required List <Map<String, dynamic>> sensorNodeList}) {
    List<Map<String,dynamic>> sensorNodes = [];

    for(var device in sensorNodeList){
      _logs.info(message: 'registeredSensorNodes type: ${device['registeredSensorNodes'].runtimeType}');
      if (device.containsKey('registeredSensorNodes')){
        List <Map<String,dynamic>> snList = device['registeredSensorNodes'];
        for (var sensorNode in snList){
          Map<String,dynamic> sensorNodeData = {
            'deviceID' : sensorNode['SNID'],
            'name' : sensorNode['SensorNode_Name'],
            'sinkNodeID' :device['SKID'],
          };
          sensorNodes.add(sensorNodeData);
        }
      }
    }
    _logs.info(message: sensorNodes.toString());
    _sharedPrefsUtils.setSNList(sensorList: sensorNodes);
  }*/

}