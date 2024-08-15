import 'package:smmic/models/device_data_models.dart';

class DeviceUtils {

  /// Helper function to map a sink node map into an object
  SinkNode sinkNodeMapToObject(Map<String, dynamic> sinkMap){
    List<Map<String, dynamic>> sensorNodes = sinkMap['sensor_nodes'];
    List<String> sensorNodeIDList = [];
    for (int i = 0; i < sensorNodes.length; i++){
      sensorNodeIDList.add((sensorNodes[i]['SNID']).toString());
    }
    Map<String, dynamic> sinkNodeMap = {
      'deviceID': sinkMap['SKID'],
      'deviceName': sinkMap['SK_Name'],
      'coordinates' : sinkMap['coordinates'],
      'registeredSensorNodes': sensorNodeIDList
    };
    return SinkNode.fromJSON(sinkNodeMap);
  }

  /// Helper function to map a sensor node map into an object
  SensorNode sensorNodeMapToObject({required Map<String, dynamic> sensorMap, required String sinkNodeID}){
    Map<String, dynamic> sensorNodeMap = {
      'deviceID': sensorMap['SNID'],
      'deviceName': sensorMap['SensorNode_Name'],
      'coordinates': sensorMap['coordinates'],
      'sinkNodeID': sinkNodeID
    };
    return SensorNode.fromJSON(sensorNodeMap);
  }
}