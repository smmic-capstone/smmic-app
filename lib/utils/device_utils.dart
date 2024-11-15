import 'package:smmic/models/device_data_models.dart';

import 'logs.dart';

class DeviceUtils {
  final Logs _logs = Logs(tag: 'Device_Utils');

  /// Helper function to map a sink node map into an object
  SinkNode sinkNodeMapToObject(Map<String, dynamic> sinkMap){
    var sensorNodes = sinkMap['sensor_nodes'];
    List<String> sensorNodeIDList = [];

    if (sensorNodes is List<Map<String, dynamic>>) {
      for (int i = 0; i < sensorNodes.length; i++){
        sensorNodeIDList.add((sensorNodes[i]['device_id']).toString().trim());
      }
    } else if (sensorNodes is List<String>) {
      for (String s in sensorNodes) {
        sensorNodeIDList.add(s.trim());
      }
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
      SensorNodeKeys.deviceID.key : sensorMap[SensorNodeKeys.deviceID.key],
      SensorNodeKeys.deviceName.key: sensorMap[SensorNodeKeys.deviceName.key],
      SensorNodeKeys.latitude.key : sensorMap[SensorNodeKeys.latitude.key],
      SensorNodeKeys.longitude.key :sensorMap[SensorNodeKeys.sinkNode.key],
      SensorNodeKeys.sinkNode.key : sinkNodeID
    };
    return SensorNode.fromJSON(sensorNodeMap);
  }
}