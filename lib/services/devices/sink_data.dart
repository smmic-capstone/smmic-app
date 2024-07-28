import 'package:smmic/models/device_data_models.dart';
import 'package:smmic/services/user_data_services.dart';

Map<String, Map<String, dynamic>> _mockSinkNodeDataSnapshot = {
  'SIqokAO1BQBHyJVK' : {'deviceID': 'SIqokAO1BQBHyJVK', 'deviceName': 'SINK NODE 1', 'batteryLevel': 71.0, 'coordinates': '8.432566921876324, 124.79107959489828'},
  'SIqokAO1BQbgyJ2K' : {'deviceID': 'SIqokAO1BQbgyJ2K', 'deviceName': 'SINK NODE 2', 'batteryLevel': 50.0}
};

class SinkNodeDataServices {

  //TODO: refactor when api is up
  SinkNodeSnapshot getSnapshot(String deviceID) {
    return SinkNodeSnapshot.json(_mockSinkNodeDataSnapshot[deviceID]!);
  }

  /// Returns SinkNode information (id, name, coordinates, registered sensor nodes) as a SinkNode object.
  SinkNode getInfo(String deviceID) {
    if (_mockSinkNodeDataSnapshot.containsKey(deviceID)) {
      List<String> sensorNodes = UserDataServices().mockSensorNodesList[deviceID]!; //TODO: REPLACE THIS TEMPORARY FIX!!!
      Map<String, dynamic> data = _mockSinkNodeDataSnapshot[deviceID]!;
      return SinkNode.factory(data['deviceID'], data['deviceName'], data['coordinates'], sensorNodes);
    }
    throw Exception('Device ID not identified!');
  }

}