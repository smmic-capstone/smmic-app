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

  Stream<DateTime> timeTickerSeconds() async* {
    while (true) {
      yield DateTime.now();
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  String relativeTimeDisplay(DateTime latestTime, DateTime currentTime) {
    Duration diff = currentTime.difference(latestTime);

    String finalString = '';

    if (diff < const Duration(minutes: 1)) {
      finalString = '<1 minute ago';
    } else if (diff >= const Duration(minutes: 1) && diff < const Duration(minutes: 2)) {
      finalString = '${diff.inMinutes} minute ago';
    } else if (diff >= const Duration(minutes: 2) && diff < const Duration(hours: 1)) {
      finalString = '${diff.inMinutes} minutes ago';
    } else if (diff >= const Duration(hours: 1) && diff < const Duration(hours: 2)) {
      finalString = '${diff.inHours} hour ago';
    } else if (diff >= const Duration(hours: 2) && diff < const Duration(days: 1)) {
      finalString = '${diff.inHours} hours ago';
    } else if (diff >= const Duration(days: 1) && diff < const Duration(days: 2)) {
      finalString = '${diff.inDays} day ago';
    } else if (diff >= const Duration(days: 2)) {
      finalString = '${diff.inDays} days ago';
    }

    return finalString;
  }

  //Wi
}