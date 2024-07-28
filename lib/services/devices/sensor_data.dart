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

Map<String, List<Map<String, dynamic>>> _mockSensorNodeTimeSeries = {
  'SEx0e9bmweebii5y' : [
    {
      'batteryLevel': 69.0,
      'soilMoisture': 65.0,
      'temperature': 23.0,
      'humidity': 62.0,
      'timestamp': DateTime.parse('2024-07-29 01:50:12.691')
    },
    {
      'batteryLevel': 67.0,
      'soilMoisture': 50.0,
      'temperature': 22.0,
      'humidity': 58.0,
      'timestamp': DateTime.parse('2024-07-30 02:10:12.691')
    },
    {
      'batteryLevel': 67.0,
      'soilMoisture': 45.0,
      'temperature': 24.0,
      'humidity': 60.0,
      'timestamp': DateTime.parse('2024-07-31 02:30:12.691')
    },
    {
      'batteryLevel': 66.0,
      'soilMoisture': 81.0,
      'temperature': 23.0,
      'humidity': 59.0,
      'timestamp': DateTime.parse('2024-08-01 02:50:12.691')
    },
    {
      'batteryLevel': 67.0,
      'soilMoisture': 78.0,
      'temperature': 23.5,
      'humidity': 61.0,
      'timestamp': DateTime.parse('2024-08-02 03:20:12.691')
    },
    {
      'batteryLevel': 66.0,
      'soilMoisture': 75.0,
      'temperature': 24.0,
      'humidity': 62.0,
      'timestamp': DateTime.parse('2024-08-03 03:40:12.691')
    },
  ]
};

class SensorNodeDataServices {

  //TODO: refactor when api is up
  SensorNodeSnapshot getSnapshot(String deviceID) {
    return SensorNodeSnapshot.fromJSON(_mockSensorNodeDataSnapshots[deviceID]!);
  }

  SensorNode getInfo(String deviceID) {
    if(_mockSensorNodeDataSnapshots[deviceID] != null) {
      Map<String, dynamic> data = _mockSensorNodeDataSnapshots[deviceID]!;
      return SensorNode.fromJSON(data);
    }
    throw Exception('Device ID not identified!');
  }

  // void updateInfo(Map<String, dynamic> newInfo) {
  //
  // }

  List<SensorNodeSnapshot> getTimeSeries(String sensorNodeID) {
    //TODO: refactor this code!!
    if (_mockSensorNodeTimeSeries.keys.contains(sensorNodeID)){
      return _mockSensorNodeTimeSeries[sensorNodeID]!.map((snapshot){
        snapshot.addAll({'deviceID':sensorNodeID});
        return SensorNodeSnapshot.fromJSON(snapshot);
      }).toList();
    } else {
      return _mockSensorNodeTimeSeries['SEx0e9bmweebii5y']!.map((snapshot){
        snapshot.addAll({'deviceID':'SEx0e9bmweebii5y'});
        return SensorNodeSnapshot.fromJSON(snapshot);
      }).toList();
    }
  }

}