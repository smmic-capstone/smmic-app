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
  factory SinkNode.factory(String deviceID, String deviceName, String? coordinates, List<String> registeredSensorNodes) {
    return SinkNode._internal(
        deviceID: deviceID,
        deviceName: deviceName,
        coordinates: coordinates,
        registeredSensorNodes: registeredSensorNodes
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
  factory SensorNode.factory(String deviceID, String deviceName, String? coordinates, String registeredSinkNode) {
    return SensorNode._internal(
        deviceID: deviceID,
        deviceName: deviceName,
        coordinates: coordinates,
        registeredSinkNode: registeredSinkNode
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

  factory SensorNodeSnapshot.json(Map<String, dynamic> data) {
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

  factory SinkNodeSnapshot.json(Map<String, dynamic> data) {
    return SinkNodeSnapshot._internal(
      deviceID: data['deviceID'],
      batteryLevel: data['batteryLevel']
    );
  }
}