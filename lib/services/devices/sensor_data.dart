import 'package:smmic/models/device_data_models.dart';

Map<String, Map<String, dynamic>> _mockSensorNodeDataSnapshots = {
  'SEx0e9bmweebii5y' : {
    'deviceID': 'SEx0e9bmweebii5y',
    'deviceName': 'DEVICE 102',
    'batteryLevel': 64.0,
    'soilMoisture': 17.0,
    'temperature': 24.0,
    'humidity': 45.0,
    'timestamp': DateTime.now(),
    'coordinates': '8.483811638661779, 124.6609420280041',
    'sinkNodeID': 'SIqokAO1BQBHyJVK'
  },
  'SEqokAO1BQBHyJVK' : {
    'deviceID': 'SEqokAO1BQBHyJVK',
    'deviceName': 'DEVICE 101',
    'batteryLevel': 69.0,
    'soilMoisture': 65.0,
    'temperature': 23.0,
    'humidity': 62.0,
    'timestamp': DateTime.now(),
    'coordinates': '8.48150220492715, 124.63526631530078',
    'sinkNodeID': 'SIqokAO1BQBHyJVK'
  }
};

class SensorNodeDataServices {

  //TODO: refactor when api is up
  SensorNodeSnapshot getSnapshot(String deviceID) {
    return SensorNodeSnapshot.json(_mockSensorNodeDataSnapshots[deviceID]!);
  }

  SensorNode getInfo(String deviceID) {
    if(_mockSensorNodeDataSnapshots[deviceID] != null) {
      Map<String, dynamic> data = _mockSensorNodeDataSnapshots[deviceID]!;
      return SensorNode.factory(data['deviceID'], data['deviceName'], data['coordinates'], data['sinkNodeID']);
    }
    throw Exception('Device ID not identified!');
  }

  void updateInfo(Map<String, dynamic> newInfo) {

  }

}