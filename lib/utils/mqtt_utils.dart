class MqttUtils {

  Map<String, dynamic>? mapSensorPayload(String payload) {
    Map<String, dynamic> finalMap = {};

    // the outer split of the payload
    List<String>? outerSplit = payload.split(';');
    finalMap.addAll({
      'device_id': outerSplit[1],
      'timestamp': outerSplit[2],
    });

    // data split
    List<String> dataSplit = outerSplit[3].split('&');
    for (String keyValue in dataSplit) {
      List<String> x = keyValue.split(':');
      try {
        finalMap.addAll({x[0]: int.parse(x[1])});
      } on FormatException catch (e) {
        return null;
        // TODO: handle
      }
    }

    return finalMap;
  }

}