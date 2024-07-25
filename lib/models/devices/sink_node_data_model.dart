class SinkNodeData {
  final String deviceID;
  final String deviceName;
  final double batteryLevel;

  SinkNodeData._internal({
    required this.deviceID,
    required this.deviceName,
    required this.batteryLevel
  });

  factory SinkNodeData.json(Map<String, dynamic> data) {
    return SinkNodeData._internal(
        deviceID: data['deviceID'],
        deviceName: data['deviceName'],
        batteryLevel: data['batteryLevel']
    );
  }
}