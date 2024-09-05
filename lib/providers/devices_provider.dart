import 'package:flutter/material.dart';
import 'package:smmic/models/device_data_models.dart';
import 'package:smmic/services/devices_services.dart';
import 'package:smmic/utils/device_utils.dart';
import 'package:smmic/utils/logs.dart';
import 'package:smmic/utils/shared_prefs.dart';

class DevicesProvider extends ChangeNotifier {
  // dependencies
  final Logs _logs = Logs(tag: 'DevicesProvider()');
  final DevicesServices _devicesServices = DevicesServices();
  final DeviceUtils _deviceUtils = DeviceUtils();
  final SharedPrefsUtils _sharedPrefsUtils = SharedPrefsUtils();

  List<SinkNode> _sinkNodeList = [];
  List<SinkNode> get sinkNodeList => _sinkNodeList;

  List<SensorNode> _sensorNodeList = [];
  List<SensorNode> get sensorNodeList => _sensorNodeList;


  Future<void> init() async {
    Map<String, dynamic>? userData = await _sharedPrefsUtils.getUserData();
    Map<String, dynamic> tokens = await _sharedPrefsUtils.getTokens(access: true);

    if(userData == null){
      return;
    }

    _logs.info(message: 'init() executing');
    List<Map<String, dynamic>>? devices = await _devicesServices.getDevices(userID: userData['UID'], token: tokens['access']);

    // map sink nodes and append items into _sinkNodeList
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
    _logs.info(message: devices.toString());

   /* _sharedPrefsUtils.setSKList(sinkList: devices);*/
    List <Map<String,dynamic>> devicesSharedPrefs = [];
    for (int i = 0; i < devices.length; i++){
      Map<String,dynamic> sink = _deviceUtils.mapSinkNode(devices[i]);

      devicesSharedPrefs.add(sink);
    }
    _sharedPrefsUtils.setSKList(sinkList: devicesSharedPrefs);

    _logs.success(message: 'init() done');
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
    if(_getSKList == [] || _getSKList == null){
      _logs.error(message:"Way sulod si _getSKList");
      return;
    }else{
      _logs.info(message: updatedSinkData.toString());
      for(int i = 0; i < _getSKList.length; i++){
        _logs.info(message: _getSKList[i]['deviceID'].toString());

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


}