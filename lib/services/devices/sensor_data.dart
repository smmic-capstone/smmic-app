part of '../devices_services.dart';

Map<String, Map<String, dynamic>> _mockSensorNodeDataSnapshots = {
  'SEx0e9bmweebii5y' : {
    'device_id': 'SEx0e9bmweebii5y',
    'deviceName': 'DEVICE 102',
    'battery_level': 64.0,
    'soil_moisture': 17.0,
    'temperature': 24.0,
    'humidity': 45.0,
    'timestamp': DateTime.now(),
    'coordinates': '8.483811638661779, 124.6609420280041',
    'sinkNodeID': 'SIqokAO1BQBHyJVK'
  },
  'SEqokAO1BQBHyJVK' : {
    'device_id': 'SEqokAO1BQBHyJVK',
    'deviceName': 'DEVICE 101',
    'battery_level': 69.0,
    'soil_moisture': 65.0,
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
      'battery_level': 69.00,
      'soil_moisture': 65.00,
      'temperature': 23.00,
      'humidity': 62.00,
      'timestamp': '2024-07-29 01:50:12.691'
    },
    {
      'battery_level': 67.00,
      'soil_moisture': 50.00,
      'temperature': 22.00,
      'humidity': 58.00,
      'timestamp': '2024-07-30 02:10:12.691'
    },
    {
      'battery_level': 67.00,
      'soil_moisture': 45.00,
      'temperature': 24.00,
      'humidity': 60.00,
      'timestamp': '2024-07-31 02:30:12.691'
    },
    {
      'battery_level': 66.00,
      'soil_moisture': 81.00,
      'temperature': 23.00,
      'humidity': 59.00,
      'timestamp': '2024-08-01 02:50:12.691'
    },
    {
      'battery_level': 67.00,
      'soil_moisture': 78.00,
      'temperature': 23.50,
      'humidity': 61.00,
      'timestamp': '2024-08-02 03:20:12.691'
    },
    {
      'battery_level': 66.00,
      'soil_moisture': 75.00,
      'temperature': 24.00,
      'humidity': 62.00,
      'timestamp': '2024-08-03 03:40:12.691'
    },
  ]
};

class _SensorNodeDataServices {
  //TODO: refactor when api is up
  SensorNodeSnapshot getSnapshot(String id) {
    return SensorNodeSnapshot.fromJSON(_mockSensorNodeDataSnapshots[id]!);
  }

  SensorNode getInfo(String id) {
    if(_mockSensorNodeDataSnapshots[id] != null) {
      Map<String, dynamic> data = _mockSensorNodeDataSnapshots[id]!;
      return SensorNode.fromJSON(data);
    }
    throw Exception('Device ID not identified!');
  }

  // void updateInfo(Map<String, dynamic> newInfo) {
  //
  // }

  List<SensorNodeSnapshot> getTimeSeries(String id) {
    //TODO: refactor this code!!
    if (_mockSensorNodeTimeSeries.keys.contains(id)){
      return _mockSensorNodeTimeSeries[id]!.map((snapshot){
        snapshot.addAll({'device_id':id});
        return SensorNodeSnapshot.fromJSON(snapshot);
      }).toList();
    } else {
      return _mockSensorNodeTimeSeries['SEx0e9bmweebii5y']!.map((snapshot){
        snapshot.addAll({'device_id':'SEx0e9bmweebii5y'});
        return SensorNodeSnapshot.fromJSON(snapshot);
      }).toList();
    }
  }
}