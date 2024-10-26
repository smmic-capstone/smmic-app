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
      'deviceID': sinkMap['device_id'],
      'deviceName': sinkMap['name'],
      'latitude' : sinkMap['latitude'],
      'longitude' : sinkMap['longitude'],
      'registeredSensorNodes': sensorNodeIDList
    };
    return SinkNode.fromJSON(sinkNodeMap);
  }

  Map<String,dynamic> mapSinkNode(Map<String, dynamic> sinkMap){
    List<Map<String, dynamic>> sensorNodes = sinkMap['sensor_nodes'];
    List<String> sensorNodeIDList = [];
    for (int i = 0; i < sensorNodes.length; i++){
      sensorNodeIDList.add((sensorNodes[i]['device_id']).toString());
    }
    Map<String, dynamic> sinkNodeMap = {
      'deviceID': sinkMap['device_id'],
      'deviceName': sinkMap['name'],
      'latitude' : sinkMap['latitude'],
      'longitude' : sinkMap['longitude'],
      'registeredSensorNodes': sensorNodeIDList
    };
    return sinkNodeMap;
  }

  /// Helper function to map a sensor node map into an object
  SensorNode sensorNodeMapToObject({required Map<String, dynamic> sensorMap, required String sinkNodeID}){
    Map<String, dynamic> sensorNodeMap = {
      'deviceID': sensorMap['device_id'],
      'deviceName': sensorMap['name'],
      'latitude': sensorMap['latitude'],
      'longitude':sensorMap['longitude'],
      'sinkNodeID': sinkNodeID
    };
    return SensorNode.fromJSON(sensorNodeMap);
  }

  Map<String,dynamic> mapSensorNode(Map<String, dynamic> sensorMap, String sinkNodeID){
    Map<String,dynamic> sinkNodeMap = {};
    try{
      sinkNodeMap = {
        'deviceID': sensorMap['device_id'],
        'deviceName': sensorMap['name'],
        'latitude': sensorMap['latitude'],
        'longitude': sensorMap['longitude'],
        'sinkNodeID': sinkNodeID

      };
    }catch(e){
      _logs.info(message: e.toString());
    }
    return sinkNodeMap;
  }

 /* Map<String,dynamic> mapSNReadings(String message){
     message.replaceAll('{', '');
     message.replaceAll('}', '');
     for(int i = 0; i < message.allMatches("{").toList().length; i++){
       message.replaceAll(from, replace)
     }
  }*/

}