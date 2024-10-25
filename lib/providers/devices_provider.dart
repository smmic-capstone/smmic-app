import 'dart:async';
import 'dart:convert';

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

class DevicesProvider extends ChangeNotifier {
  // dependencies
  final Logs _logs = Logs(tag: 'DevicesProvider()');
  final DevicesServices _devicesServices = DevicesServices();
  final DeviceUtils _deviceUtils = DeviceUtils();
  final SharedPrefsUtils _sharedPrefsUtils = SharedPrefsUtils();
  final ApiRequest _apiRequest = ApiRequest();
  final ApiRoutes _apiRoutes = ApiRoutes();

  List<SinkNode> _sinkNodeList = [];
  List<SinkNode> get sinkNodeList => _sinkNodeList;

  List<SensorNode> _sensorNodeList = [];
  List<SensorNode> get sensorNodeList => _sensorNodeList;

  ///Websocket Connections
  final StreamController<SensorNodeSnapshot> _sensorReadingsController = StreamController.broadcast();
  Stream<SensorNodeSnapshot> get sensorReadingsStream => _sensorReadingsController.stream;
  StreamSubscription<SensorNodeSnapshot>? _streamSubscription;


  Map<String,Map<String,dynamic>> _sensorReadings = {};
  Map<String,Map<String,dynamic>> get sensorReadings => _sensorReadings;


  Future<void> init() async {
    Map<String, dynamic>? userData = await _sharedPrefsUtils.getUserData();
    Map<String, dynamic> tokens = await _sharedPrefsUtils.getTokens(access: true);

    if(userData == null){
      return;
    }

    _logs.info(message: 'init() executing');
    List<Map<String, dynamic>>? devices = await _devicesServices.getDevices(userID: userData['UID'], token: tokens['access']);

    // map sink nodes and append items into _sinkNodeList
    _logs.info(message: 'devices init: $devices');
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
        SensorNode sensor = _deviceUtils.sensorNodeMapToObject(sensorMap: sensorNodeList[x], sinkNodeID: devices[i]['SKID']);
        if (_sensorNodeList.isNotEmpty && _sensorNodeList.any((item) => item.deviceID == sensor.deviceID)) {
          continue;
        }
        _sensorNodeList.add(sensor);
      }
    }
    _logs.info(message: "devices : $devices");

   /* _sharedPrefsUtils.setSKList(sinkList: devices);*/
    List <Map<String,dynamic>> sinkNodeSharedPrefs = [];
    List<Map<String,dynamic>> sensorNodeSharedPrefs = [];
    for (int i = 0; i < devices.length; i++){
      Map<String,dynamic> sink = _deviceUtils.mapSinkNode(devices[i]);

      sinkNodeSharedPrefs.add(sink);
      for(int j =0; j < devices[i]["sensor_nodes"].length; j++){
        Map<String,dynamic> sensor = _deviceUtils.mapSensorNode(devices[i]['sensor_nodes'][j], sink['deviceID']);

        sensorNodeSharedPrefs.add(sensor);
      }
    }
    _sharedPrefsUtils.setSKList(sinkList: sinkNodeSharedPrefs);
    _logs.info(message: "deviceSharedPrefs data type: ${sinkNodeSharedPrefs.runtimeType}");
    _sharedPrefsUtils.setSNList(sensorList: sensorNodeSharedPrefs);
    /*extractSensorNodes(sensorNodeList: devices);*/

    _logs.success(message: 'init() done');
    _logs.info(message: 'devices shared prefs init: $sinkNodeSharedPrefs');
    notifyListeners();

    listenToStream();
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

  void setSNReadings ({required Map<String,dynamic> sensorReadings }) async {
    _logs.info(message: "setSNreadings running : $sensorReadings");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('last_reading',jsonEncode(sensorReadings));
    _logs.info(message: 'prefs running');
    notifyListeners();

    /* final String sensorID = sensorReadings['message']['Sensor_Node'];
    _sensorReadings[sensorID] = sensorReadings['message'];*/
  }

  Future <Map<String,dynamic>> getLastReadings() async {
    _logs.info(message: "getSNreadings running");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? reading = prefs.getString('last_reading');
    if (reading != null){
      return jsonDecode(reading);
    }else{
      return {};
    }
  }


  
  void listenToStream() {
    _logs.info(message: 'Connecting to Websocket');
    _apiRequest.channelConnect(route: _apiRoutes.getSNReadings);
    _streamSubscription = _sensorReadingsController.stream.listen((SensorNodeSnapshot data) async {
      await DatabaseHelper.addReadings(data);
      _logs.info(message: 'Stream Data: $data');
      _logs.info(message: 'Stream Data Type: ${data.runtimeType}');
      notifyListeners();
    }, onError: (error){
      _logs.error(message: '$error');
    });

  }



  void disconnectToWebSocket(){
    _sensorReadingsController.close();
  }

  /*void connectToWebSocket(){
    _logs.info(message: "websocket connecting");
    _apiRequest.channelConnect(route: _apiRoutes.getSNReadings)?.listen((data){
      final mappedData = jsonDecode(data.toString());
      _sensorReadingsController.add(mappedData);
      setSNReadings(sensorReadings: mappedData);
      _logs.info(message: 'mappedData type: $mappedData');
    });
  }*/

  ///WebSocket Connections in Background

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