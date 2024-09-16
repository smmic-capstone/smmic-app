part of '../devices_services.dart';

class _SinkNodeDataServices {

  //TODO: refactor when api is up
  // SinkNodeSnapshot getSnapshot(String deviceID) {
  //   return SinkNodeSnapshot.fromJSON(_mockSinkNodeDataSnapshot[deviceID]!);
  // }

  /// Returns SinkNode information (id, name, coordinates, registered sensor nodes) as a SinkNode object.
  // SinkNode getInfo(String deviceID) {
  //   if (_mockSinkNodeDataSnapshot.containsKey(deviceID)) {
  //     List<String> sensorNodes = UserDataServices().getSensorNodes(deviceID); //TODO: REPLACE THIS TEMPORARY FIX!!!
  //     Map<String, dynamic> data = _mockSinkNodeDataSnapshot[deviceID]!;
  //     data.addAll({'registeredSensorNodes': sensorNodes});
  //     return SinkNode.fromJSON(data);
  //   }
  //   throw Exception('Device ID not identified!');
  // }

  // Future<Map<String, dynamic>> getInfo() {
  //
  // }

}