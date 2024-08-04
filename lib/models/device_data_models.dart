import 'package:flutter/material.dart';

class Device {
  final String deviceID;
  String deviceName;
  String? coordinates;

  Device({required this.deviceID, required this.deviceName, this.coordinates});

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
    super.coordinates,
    required this.registeredSensorNodes
  }) : super();

  //TODO: add logic to check if a device already exists (caching or from shared prefs)
  factory SinkNode.fromJSON(Map<String, dynamic> deviceInfo) {
    return SinkNode._internal(
      deviceID: deviceInfo['deviceID'],
      deviceName: deviceInfo['deviceName'],
      coordinates: deviceInfo['coordinates'],
      registeredSensorNodes: deviceInfo['registeredSensorNodes']
    );
  }
}

class SensorNode extends Device {
  final String registeredSinkNode;
  
  SensorNode._internal({
    required super.deviceID,
    required super.deviceName,
    super.coordinates,
    required this.registeredSinkNode
  }) : super();

  //TODO: add logic to check if a device already exists (caching or from shared prefs)
  factory SensorNode.fromJSON(Map<String, dynamic> deviceInfo) {
    return SensorNode._internal(
      deviceID: deviceInfo['deviceID'],
      deviceName: deviceInfo['deviceName'],
      coordinates: deviceInfo['coordinates'],
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
    return SensorNodeSnapshot._internal(
      deviceID: data['deviceID'],
      timestamp: data['timestamp'],
      soilMoisture: data['soilMoisture'],
      temperature: data['temperature'],
      humidity: data['humidity'],
      batteryLevel: data['batteryLevel'],
    );
  }
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