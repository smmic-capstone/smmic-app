import 'dart:math';

Map<String, List<String>> mockSensorNodesList = {
  'SIqokAO1BQBHyJVK' : ['SEx0e9bmweebii5y', 'SEqokAO1BQBHyJVK']
};

List<String> mockSinkNodesList = [
  'SIqokAO1BQBHyJVK',
  'SIqokAO1BQbgyJ2K'
];

class UserDataServices {

  //TODO: refactor when api is up
  List<String> getSensorNodes(String sinkNodeID) {
    return mockSensorNodesList[sinkNodeID] ?? [];
  }

  List<String> getSinkNodes() {
    return mockSinkNodesList;
  }

}