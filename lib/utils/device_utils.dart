import 'package:smmic/models/device_data_models.dart';

import 'logs.dart';

class DeviceUtils {
  final Logs _logs = Logs(tag: 'Device_Utils');

  /// Helper function to map a sink node map into an object
  SinkNode sinkNodeMapToObject(Map<String, dynamic> sinkMap){
    List<Map<String, dynamic>> sensorNodes = sinkMap['sensor_nodes'];
    List<String> sensorNodeIDList = [];
    for (int i = 0; i < sensorNodes.length; i++){
      sensorNodeIDList.add((sensorNodes[i]['device_id']).toString());
    }
    Map<String, dynamic> sinkNodeMap = {
      SinkNodeKeys.deviceID.key : sinkMap[SinkNodeKeys.deviceID.key],
      SinkNodeKeys.deviceName.key : sinkMap[SinkNodeKeys.deviceName.key],
      SinkNodeKeys.latitude.key : sinkMap[SinkNodeKeys.latitude.key],
      SinkNodeKeys.longitude.key : sinkMap[SinkNodeKeys.longitude.key],
      SinkNodeKeys.registeredSensorNodes.key : sensorNodeIDList
    };
    return SinkNode.fromJSON(sinkNodeMap);
  }

  /// Helper function to map a sensor node map into an object
  SensorNode sensorNodeMapToObject({required Map<String, dynamic> sensorMap, required String sinkNodeID}){
    Map<String, dynamic> sensorNodeMap = {
      SensorNodeKeys.deviceID.key : sensorMap['device_id'],
      SensorNodeKeys.deviceName.key: sensorMap['name'],
      SensorNodeKeys.latitude.key : sensorMap['latitude'],
      SensorNodeKeys.longitude.key :sensorMap['longitude'],
      SensorNodeKeys.sinkNode.key : sinkNodeID
    };
    return SensorNode.fromJSON(sensorNodeMap);
  }
}