import 'package:smmic/models/devices/sensor_node_data_model.dart';

Map<String, Map<String, dynamic>> _mockSensorNodeDataSnapshots = {
  'SEx0e9bmweebii5y' : {
    'deviceID': 'SEx0e9bmweebii5y',
    'deviceName': 'DEVICE 102',
    'batteryLevel': 64.0,
    'soilMoisture': 17.0,
    'temperature': 24.0,
    'humidity': 45.0,
    'timestamp': DateTime.now(),
    'coordinates': '8.483811638661779, 124.6609420280041'
  },
  'SEqokAO1BQBHyJVK' : {
    'deviceID': 'SEqokAO1BQBHyJVK',
    'deviceName': 'DEVICE 101',
    'batteryLevel': 69.0,
    'soilMoisture': 65.0,
    'temperature': 23.0,
    'humidity': 62.0,
    'timestamp': DateTime.now(),
    'coordinates': '8.48150220492715, 124.63526631530078'
  }
};

class SensorNodeDataServices {

  //TODO: refactor when api is up
  SensorNodeData getSnapshot(String deviceID) {
    return SensorNodeData.json(_mockSensorNodeDataSnapshots[deviceID]!);
  }

}