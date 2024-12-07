import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';

enum SinkNodeKeys {
  deviceID('device_id'),
  deviceName('name'),
  latitude('latitude'),
  longitude('longitude'),
  registeredSensorNodes('sensor_nodes');

  final String key;
  const SinkNodeKeys(this.key);
}

enum SinkNodeSnapshotKeys {
  deviceID('device_id'),
  timestamp('timestamp'),
  batteryLevel('battery_level'),
  connectedClients('connected_clients'),
  totalClients('total_clients'),
  subCount('sub_count'),
  bytesSent('bytes_sent'),
  bytesReceived('bytes_received'),
  messagesSent('messages_sent'),
  messagesReceived('messages_received');

  final String key;
  const SinkNodeSnapshotKeys(this.key);
}

enum SensorNodeKeys {
  deviceID('device_id'),
  deviceName('name'),
  latitude('latitude'),
  longitude('longitude'),
  sinkNode('sink_node');

  final String key;
  const SensorNodeKeys(this.key);
}

enum SMSensorSnapshotKeys {
  deviceID('device_id'),
  timestamp('timestamp'),
  soilMoisture('soil_moisture'),
  temperature('temperature'),
  humidity('humidity'),
  batteryLevel('battery_level');

  final String key;
  const SMSensorSnapshotKeys(this.key);
}

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
  List<String> registeredSensorNodes;

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
      deviceID: deviceInfo[SinkNodeKeys.deviceID.key],
      deviceName: deviceInfo[SinkNodeKeys.deviceName.key],
      longitude: deviceInfo[SinkNodeKeys.longitude.key],
      latitude: deviceInfo[SinkNodeKeys.latitude.key],
      registeredSensorNodes: deviceInfo[SinkNodeKeys.registeredSensorNodes.key]
    );
  }

  String toHash() {
    return sha256.convert(
        utf8.encode('$deviceName$latitude$longitude$registeredSensorNodes')
    ).toString();
  }

  void update(SinkNode newData) {
    deviceName = newData.deviceName;
    latitude = newData.latitude;
    longitude = newData.longitude;
    registeredSensorNodes = newData.registeredSensorNodes;
  }
}

class SinkNodeState {
  final String deviceID;
  DateTime lastTransmission;
  double batteryLevel;
  int connectedClients;
  int totalClients;
  int subCount;
  int bytesSent;
  int bytesReceived;
  int messagesSent;
  int messagesReceived;
  Map<String, ConnectionState> sensorsConnectionStateMap;

  SinkNodeState._internal({
    required this.deviceID,
    required this.lastTransmission,
    required this.batteryLevel,
    required this.connectedClients,
    required this.totalClients,
    required this.subCount,
    required this.bytesSent,
    required this.bytesReceived,
    required this.messagesSent,
    required this.messagesReceived,
    this.sensorsConnectionStateMap = const {}
  });

  factory SinkNodeState.initObj(String deviceId) {
    // TODO: load from shared prefs
    return SinkNodeState._internal(
        deviceID: deviceId,
        lastTransmission: DateTime.now(),
        batteryLevel: 0.0,
        connectedClients: 0,
        totalClients: 0,
        subCount: 0,
        bytesSent: 0,
        bytesReceived: 0,
        messagesSent: 0,
        messagesReceived: 0
    );
  }

  //{"battery_level":"0.0000000",
  // "timestamp":"2024-11-20T17:02:01.747699+08:00",
  // "connected_clients":2,
  // "total_clients":2,
  // "sub_count":15,
  // "bytes_sent":219776,
  // "bytes_received":199719,
  // "messages_sent":3448,
  // "messages_received":3487}
  factory SinkNodeState.fromJSON(Map<String, dynamic> data, String sinkId) {
    return SinkNodeState._internal(
        deviceID: sinkId,
        lastTransmission: DateTime.parse(data[SinkNodeSnapshotKeys.timestamp.key]),
        batteryLevel: data[SinkNodeSnapshotKeys.batteryLevel.key],
        connectedClients: data[SinkNodeSnapshotKeys.connectedClients.key],
        totalClients: data[SinkNodeSnapshotKeys.totalClients.key],
        subCount: data[SinkNodeSnapshotKeys.subCount.key],
        bytesSent: data[SinkNodeSnapshotKeys.bytesSent.key],
        bytesReceived: data[SinkNodeSnapshotKeys.bytesReceived.key],
        messagesSent: data[SinkNodeSnapshotKeys.messagesSent.key],
        messagesReceived: data[SinkNodeSnapshotKeys.messagesReceived.key]
    );
  }

  void updateState(Map<String, dynamic> data) {
    lastTransmission = DateTime.parse(data[SinkNodeSnapshotKeys.timestamp.key]);
    batteryLevel = double.parse(data[SinkNodeSnapshotKeys.batteryLevel.key]);
    connectedClients = data[SinkNodeSnapshotKeys.connectedClients.key];
    totalClients = data[SinkNodeSnapshotKeys.totalClients.key];
    subCount = data[SinkNodeSnapshotKeys.subCount.key];
    bytesSent = data[SinkNodeSnapshotKeys.bytesSent.key];
    bytesReceived = data[SinkNodeSnapshotKeys.bytesReceived.key];
    messagesSent = data[SinkNodeSnapshotKeys.messagesSent.key];
    messagesReceived = data[SinkNodeSnapshotKeys.messagesReceived.key];
  }

  void setSensorConnectionState(String sensorId, ConnectionState state) {
    sensorsConnectionStateMap[sensorId] = state;
  }

}

class SensorNode extends Device {
  String registeredSinkNode;
  
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
      deviceID: deviceInfo[SensorNodeKeys.deviceID.key],
      deviceName: deviceInfo[SensorNodeKeys.deviceName.key],
      latitude:deviceInfo[SensorNodeKeys.latitude.key],
      longitude: deviceInfo[SensorNodeKeys.longitude.key],
      registeredSinkNode: deviceInfo[SensorNodeKeys.sinkNode.key]
    );
  }

  String toHash() {
    return sha256.convert(
      utf8.encode('$deviceName$longitude$latitude$registeredSinkNode')
    ).toString();
  }
  
  void update(SensorNode newData) {
    deviceName = newData.deviceName;
    longitude = newData.longitude;
    latitude = newData.latitude;
    registeredSinkNode = newData.registeredSinkNode;
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

  @override
  String toString() {
    return 'SensorNodeSnapshot object -> ${SMSensorSnapshotKeys.deviceID.key}: $deviceID,'
        '${SMSensorSnapshotKeys.timestamp.key}: $timestamp,'
        '${SMSensorSnapshotKeys.soilMoisture.key}: $soilMoisture,'
        '${SMSensorSnapshotKeys.temperature.key}: $temperature,'
        '${SMSensorSnapshotKeys.humidity.key}: $humidity,'
        '${SMSensorSnapshotKeys.batteryLevel.key}: $batteryLevel';
  }

  factory SensorNodeSnapshot.fromJSON(Map<String, dynamic> data) {
    // the data contains a 'data' key, it is an alert message
    final dataValues = data.containsKey('data') ? data['data'] : data;
    return SensorNodeSnapshot._internal(
      deviceID: data[SMSensorSnapshotKeys.deviceID.key],
      timestamp: DateTime.parse(data[SMSensorSnapshotKeys.timestamp.key]).toLocal(),
      soilMoisture: double.parse(
          dataValues[SMSensorSnapshotKeys.soilMoisture.key]
              .toString()
      ),
      temperature: double.parse(
          dataValues[SMSensorSnapshotKeys.temperature.key]
              .toString()
      ),
      humidity: double.parse(
          dataValues[SMSensorSnapshotKeys.humidity.key]
              .toString()
      ),
      batteryLevel: double.parse(
          dataValues[SMSensorSnapshotKeys.batteryLevel.key]
              .toString()
      ),
    );
  }

  factory SensorNodeSnapshot.placeHolder({required String deviceId, DateTime? timestamp}) {
    return SensorNodeSnapshot._internal(
        deviceID: deviceId,
        timestamp: timestamp ?? DateTime.now(),
        soilMoisture: 0,
        temperature: 0,
        humidity: 0,
        batteryLevel: 0
    );
  }

  static SensorNodeSnapshot? dynamicSerializer({required var data}) {
    SensorNodeSnapshot? finalSnapshot;

    if (data is Map<String, dynamic>) {
      // TODO: verify keys first
      finalSnapshot = SensorNodeSnapshot.fromJSON(data);

    } else if (data is String) {
      // assuming that if the reading variable is a string, it is an mqtt payload
      Map<String, dynamic> fromStringMap = {};
      List<String> outerSplit = data.split(';');

      fromStringMap.addAll({
        'device_id': outerSplit[1],
        'timestamp': outerSplit[2],
      });

      List<String> dataSplit = outerSplit[3].split('&');

      for (String keyValue in dataSplit) {
        try {
          List<String> x = keyValue.split(':');
          fromStringMap.addAll({x[0]: x[1]});
        } on FormatException catch (e) {
          break;
        }
      }

      // create a new sensor node snapshot object from the new string map
      finalSnapshot = SensorNodeSnapshot.fromJSON(fromStringMap);

    } else if (data is SensorNodeSnapshot) {
      finalSnapshot = data;

    }

    return finalSnapshot;
  }

  Map<String,dynamic> toJson() => {
    SMSensorSnapshotKeys.deviceID.key : deviceID,
    SMSensorSnapshotKeys.timestamp.key : timestamp.toIso8601String(),
    SMSensorSnapshotKeys.soilMoisture.key : soilMoisture,
    SMSensorSnapshotKeys.temperature.key : temperature,
    SMSensorSnapshotKeys.humidity.key : humidity,
    SMSensorSnapshotKeys.batteryLevel.key: batteryLevel
  };
}

enum SMSensorAlertCodes {
  connectedState(1),
  disconnectedState(0),

  // alertCode identifiers
  connectionState(-1),
  soilMoistureAlert(4),
  temperatureAlert(3),
  humidityAlert(2),
  irrAlert(1),

  // soil moisture
  soilMoistureLow(40),
  soilMoistureNormal(41),
  soilMoistureHigh(42),

  // temperature
  temperatureLow(30),
  temperatureNormal(31),
  temperatureHigh(32),

  // humidity
  humidityLow(20),
  humidityNormal(21),
  humidityHigh(22),

  // battery
  lowBattery(50),
  normalBattery(51),

  // irrigation states
  irrOn(11),
  irrOff(10);

  final int code;
  const SMSensorAlertCodes(this.code);
}

enum SensorAlertKeys {
  deviceID('device_id'),
  timestamp('timestamp'),
  alertCode('alert_code'),
  data('data');

  final String key;
  const SensorAlertKeys(this.key);
}

class SMSensorState {
  final String deviceID;
  DateTime lastUpdate;
  /// The time that *individual* states are kept before they 'expire'
  static Duration keepStateTime = const Duration(minutes: 10);

  // states are a tuple of:
  // 1. the current state code / alert code received from the web socket
  // 2. the timestamp when the alert was received
  // 3. the timestamp it should 'expire'

  /// The device connection state (0, 1),
  /// the timestamp of the last transmission,
  /// and the expiry of the transmission.
  (int, DateTime, DateTime) connectionState;
  /// The soil moisture state, timestamp of the transmission
  /// and the expected expiry
  (int, DateTime, DateTime) soilMoistureState;
  /// The humidity state, timestamp of the transmission
  /// and the expected expiry
  (int, DateTime, DateTime) humidityState;
  /// The temperature state, timestamp of the transmission
  /// and the expected expiry
  (int, DateTime, DateTime) temperatureState;
  /// The battery state, timestamp of the transmission
  /// and the expected expiry
  (int, DateTime, DateTime) batteryState;
  /// The irrigation state, timestamp of the transmission
  /// and the expected expiry
  (int, DateTime, DateTime) irrigationState;

  SMSensorState._internal({
    required this.deviceID,
    required this.lastUpdate,
    required this.connectionState,
    required this.soilMoistureState,
    required this.humidityState,
    required this.temperatureState,
    required this.batteryState,
    required this.irrigationState
  });

  /// Initiate the soil moisture sensor state with the default values.
  /// This method **should** only be called with device provider init.
  factory SMSensorState.initObj(String sensorId){
    // TODO: init from sharedprefs
    return SMSensorState._internal(
        deviceID: sensorId,
        lastUpdate: DateTime.now(),
        connectionState: (
            SMSensorAlertCodes.disconnectedState.code,
            DateTime.now(),
            DateTime.now().add(keepStateTime)
        ),
      soilMoistureState: (
          SMSensorAlertCodes.soilMoistureNormal.code,
          DateTime.now(),
          DateTime.now().add(keepStateTime)
      ),
      humidityState: (
          SMSensorAlertCodes.humidityNormal.code,
          DateTime.now(),
          DateTime.now().add(keepStateTime)
      ),
      temperatureState: (
          SMSensorAlertCodes.temperatureNormal.code,
          DateTime.now(),
          DateTime.now().add(keepStateTime)
      ),
      batteryState: (
          SMSensorAlertCodes.normalBattery.code,
          DateTime.now(),
          DateTime.now().add(keepStateTime)
      ),
      irrigationState: (
          SMSensorAlertCodes.irrOff.code,
          DateTime.now(),
          DateTime.now().add(keepStateTime)
      ),
    );
  }

  void updateState(Map<String, dynamic> alertMap) {
    lastUpdate = DateTime.parse(alertMap[SensorAlertKeys.timestamp.key]);

    DateTime alertTimeStamp = DateTime.parse(
        alertMap[SensorAlertKeys.timestamp.key]
    );
    int alertCode = int.parse(alertMap[SensorAlertKeys.alertCode.key]);
    int alertType = alertCode ~/ 10;

    if (alertCode == 1 || alertCode == 0) {
      connectionState = (
          alertCode,
          alertTimeStamp,
          alertTimeStamp.add(keepStateTime)
      );
      return;
    }

    if (alertType == SMSensorAlertCodes.soilMoistureAlert.code) {
      soilMoistureState = (
          alertCode,
          alertTimeStamp,
          alertTimeStamp.add(keepStateTime)
      );
    } else if (alertType == SMSensorAlertCodes.temperatureAlert.code) {
      temperatureState = (
          alertCode,
          alertTimeStamp,
          alertTimeStamp.add(keepStateTime)
      );
    } else if (alertType == SMSensorAlertCodes.humidityAlert.code) {
      humidityState = (
          alertCode,
          alertTimeStamp,
          alertTimeStamp.add(keepStateTime)
      );
    } else if (alertType == SMSensorAlertCodes.irrAlert.code) {
      irrigationState = (
          alertCode,
          alertTimeStamp,
          alertTimeStamp.add(keepStateTime)
      );
    }

    // update connection state to 1 if received alert is
    // not a connection state alert
    connectionState = (
        1,
        alertTimeStamp,
        alertTimeStamp.add(keepStateTime)
    );
  }
}