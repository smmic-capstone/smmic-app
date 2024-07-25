List<String> mockSensorNodesList = [
  'SEx0e9bmweebii5y',
  'SEqokAO1BQBHyJVK'
];

List<String> mockSinkNodesList = [
  'SIqokAO1BQBHyJVK'
];

class UserDataServices {

  //TODO: refactor when api is up
  List<String> getSensorNodes() {
    return mockSensorNodesList;
  }

  List<String> getSinkNodes() {
    return mockSinkNodesList;
  }

}