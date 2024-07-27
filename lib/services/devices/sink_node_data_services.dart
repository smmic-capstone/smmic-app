import 'package:smmic/models/devices/sink_node_data_model.dart';

Map<String, Map<String, dynamic>> _mockSinkNodeDataSnapshot = {
  'SIqokAO1BQBHyJVK' : {'deviceID': 'SIqokAO1BQBHyJVK', 'deviceName': 'SINK NODE 1', 'batteryLevel': 71.0},
  'SIqokAO1BQbgyJ2K' : {'deviceID': 'SIqokAO1BQbgyJ2K', 'deviceName': 'SINK NODE 2', 'batteryLevel': 50.0}
};

class SinkNodeDataServices {

  //TODO: refactor when api is up
  SinkNodeData getSnapshot(String deviceID) {
    return SinkNodeData.json(_mockSinkNodeDataSnapshot[deviceID]!);
  }

}