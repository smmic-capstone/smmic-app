import 'dart:convert';

class Device {
  final String deviceID;
  String deviceName;
  String? longitude;
  String? latitude;

  Device({required this.deviceID, required this.deviceName, this.longitude, this.latitude});

  //Updates the device information (deviceName and deviceID) of the object instance
  // void updateInfo(Map<String, dynamic> newInfo) {
  //   if (newInfo.containsKey('deviceName') && newInfo['deviceName'] != deviceName) {
  //     deviceName = newInfo['deviceName'];
  //   }
  //   if (newInfo.containsKey('coordinates') && newInfo['coordinates'] != coordinates) {
  //     coordinates = newInfo['coordinates'];
  //   }
  // }
}

class SinkNode extends Device {
  final List<String> registeredSensorNodes;

  SinkNode._internal({
    required super.deviceID,
    required super.deviceName,
    super.latitude,
    super.longitude,
    required this.registeredSensorNodes
  }) : super();

  //TODO: add logic to check if a device already exists (caching or from shared prefs)
  factory SinkNode.fromJSON(Map<String, dynamic> deviceInfo) {
    return SinkNode._internal(
      deviceID: deviceInfo['deviceID'],
      deviceName: deviceInfo['deviceName'],
      longitude: deviceInfo['longitude'],
      latitude: deviceInfo['latitude'],
      registeredSensorNodes: deviceInfo['registeredSensorNodes']
    );
  }
}

class SensorNode extends Device {
  final String registeredSinkNode;
  
  SensorNode._internal({
    required super.deviceID,
    required super.deviceName,
    super.longitude,
    super.latitude,
    required this.registeredSinkNode
  }) : super();

  //TODO: add logic to check if a device already exists (caching or from shared prefs)
  factory SensorNode.fromJSON(Map<String, dynamic> deviceInfo) {
    return SensorNode._internal(
      deviceID: deviceInfo['deviceID'],
      deviceName: deviceInfo['deviceName'],
      latitude:deviceInfo['latitude'],
      longitude: deviceInfo['longitude'],
      registeredSinkNode: deviceInfo['sinkNodeID']
    );
  }
}

class SensorNodeSnapshot {
  final String deviceID;
  final DateTime timestamp;
  final double soilMoisture;
  final double temperature;
  final double humidity;
  final double batteryLevel;

  SensorNodeSnapshot._internal({
    required this.deviceID,
    required this.timestamp,
    required this.soilMoisture,
    required this.temperature,
    required this.humidity,
    required this.batteryLevel,
  });

  factory SensorNodeSnapshot.fromJSON(Map<String, dynamic> data) {
    final dataValues = data.containsKey('data') ? data['data'] : data;
    return SensorNodeSnapshot._internal(
      deviceID: data['device_id'],
      timestamp: DateTime.parse(data['timestamp']),
      soilMoisture: double.parse(dataValues['soil_moisture'].toString()),
      temperature: double.parse(dataValues['temperature'].toString()),
      humidity: double.parse(dataValues['humidity'].toString()),
      batteryLevel: double.parse(dataValues['battery_level'].toString()),
    );
  }

  Map<String,dynamic> toJson() => {
    'device_id' : deviceID,
    'timestamp' : timestamp.toIso8601String(),
    'soil_moisture' : soilMoisture,
    'temperature' : temperature,
    'humidity' : humidity,
    'battery_level': batteryLevel
  };

  @override
  String toString(){
    return 'SensorNodeSnapshot(deviceID: $deviceID, timestamp: $timestamp, soilMoisture: $soilMoisture, '
        'temperature: $temperature, humidity: $humidity, batteryLevel: $batteryLevel)';
  }
}

class SMAlerts {
  final String deviceID;
  final DateTime timestamp;
  final int alerts;
  final Map<String,dynamic> data;

  SMAlerts._internal({
    required this.deviceID,
    required this.timestamp,
    required this.alerts,
    required this.data
  });

  factory SMAlerts.fromJSON(Map<String,dynamic> data){
    return SMAlerts._internal(
        deviceID: data['device_id'],
        timestamp: DateTime.parse(data['timestamp']),
        alerts: data['alert_code'],
        data: data['data']
    );
  }

  Map<String,dynamic> toJson() => {
    "device_id" : deviceID,
    "timestamp" : timestamp.toIso8601String(),
    "alerts" : alerts,
    "data" : data,
  };
}

//TODO: Add other data fields
class SinkNodeSnapshot {
  final String deviceID;
  final double batteryLevel;

  SinkNodeSnapshot._internal({
    required this.deviceID,
    required this.batteryLevel
  });

  factory SinkNodeSnapshot.fromJSON(Map<String, dynamic> data) {
    return SinkNodeSnapshot._internal(
      deviceID: data['deviceID'],
      batteryLevel: data['batteryLevel']
    );
  }
}