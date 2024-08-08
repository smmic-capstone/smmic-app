part of '../devices_services.dart';

Map<String, Map<String, dynamic>> _mockSinkNodeDataSnapshot = {
  'SIqokAO1BQBHyJVK' : {'deviceID': 'SIqokAO1BQBHyJVK', 'deviceName': 'SINK NODE 1', 'batteryLevel': 71.0, 'coordinates': '8.432566921876324, 124.79107959489828'},
  'SIqokAO1BQbgyJ2K' : {'deviceID': 'SIqokAO1BQbgyJ2K', 'deviceName': 'SINK NODE 2', 'batteryLevel': 50.0}
};

class _SinkNodeDataServices {

  //TODO: refactor when api is up
  SinkNodeSnapshot getSnapshot(String deviceID) {
    return SinkNodeSnapshot.fromJSON(_mockSinkNodeDataSnapshot[deviceID]!);
  }

  /// Returns SinkNode information (id, name, coordinates, registered sensor nodes) as a SinkNode object.
  SinkNode getInfo(String deviceID) {
    if (_mockSinkNodeDataSnapshot.containsKey(deviceID)) {
      List<String> sensorNodes = UserDataServices().getSensorNodes(deviceID); //TODO: REPLACE THIS TEMPORARY FIX!!!
      Map<String, dynamic> data = _mockSinkNodeDataSnapshot[deviceID]!;
      data.addAll({'registeredSensorNodes': sensorNodes});
      return SinkNode.fromJSON(data);
    }
    throw Exception('Device ID not identified!');
  }

}