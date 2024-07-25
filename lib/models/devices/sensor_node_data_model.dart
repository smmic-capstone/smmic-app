import 'package:flutter/material.dart';

class SensorNodeData {
  final String deviceID;
  final String deviceName;
  final DateTime timestamp;
  final double soilMoisture;
  final double temperature;
  final double humidity;
  final double batteryLevel;

  SensorNodeData._internal({
    required this.deviceID,
    required this.deviceName,
    required this.timestamp,
    required this.soilMoisture,
    required this.temperature,
    required this.humidity,
    required this.batteryLevel
  });

  factory SensorNodeData.json(Map<String, dynamic> data) {
    return SensorNodeData._internal(
        deviceID: data['deviceID'],
        deviceName: data['deviceName'],
        timestamp: data['timestamp'],
        soilMoisture: data['soilMoisture'],
        temperature: data['temperature'],
        humidity: data['humidity'],
        batteryLevel: data['batteryLevel']
    );
  }

}