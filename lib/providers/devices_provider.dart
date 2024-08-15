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

    if(userData == null){
      return;
    }

    _logs.info(message: 'init() executing');
    List<Map<String, dynamic>>? devices = await _devicesServices.getDevices(userID: userData['UID']);

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

    _logs.success(message: 'init() done');
    notifyListeners();
  }


}