import 'dart:convert';

enum SinkNodeKeys {
  deviceID('device_id'),
  deviceName('name'),
  latitude('latitude'),
  longitude('longitude'),
  registeredSensorNodes('sensor_nodes');

  final String key;
  const SinkNodeKeys(this.key);
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

enum SensorAlertKeys {
  deviceID('device_id'),
  timestamp('timestamp'),
  alertCode('alert_code'),
  data('data');
  
  final String key;
  const SensorAlertKeys(this.key);
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
      deviceID: deviceInfo[SinkNodeKeys.deviceID.key],
      deviceName: deviceInfo[SinkNodeKeys.deviceName.key],
      longitude: deviceInfo[SinkNodeKeys.longitude.key],
      latitude: deviceInfo[SinkNodeKeys.latitude.key],
      registeredSensorNodes: deviceInfo[SinkNodeKeys.registeredSensorNodes.key]
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
      deviceID: deviceInfo[SensorNodeKeys.deviceID.key],
      deviceName: deviceInfo[SensorNodeKeys.deviceName.key],
      latitude:deviceInfo[SensorNodeKeys.latitude.key],
      longitude: deviceInfo[SensorNodeKeys.longitude.key],
      registeredSinkNode: deviceInfo[SensorNodeKeys.sinkNode.key]
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
    // the data contains a 'data' key, it is an alert message
    final dataValues = data.containsKey('data') ? data['data'] : data;
    return SensorNodeSnapshot._internal(
      deviceID: data[SMSensorSnapshotKeys.deviceID.key],
      timestamp: DateTime.parse(data[SMSensorSnapshotKeys.timestamp.key]),
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

  factory SensorNodeSnapshot.placeHolder({required String deviceId}) {
    return SensorNodeSnapshot._internal(
        deviceID: deviceId,
        timestamp: DateTime.now(),
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

  @override
  String toString(){
    return 'SensorNodeSnapshot(deviceID: $deviceID, timestamp: $timestamp, soilMoisture: $soilMoisture, '
        'temperature: $temperature, humidity: $humidity, batteryLevel: $batteryLevel)';
  }
}

class SensorAlerts {
  final String deviceID;
  final DateTime timestamp;
  final int alertCode;
  final Map<String,dynamic> data;

  SensorAlerts._internal({
    required this.deviceID,
    required this.timestamp,
    required this.alertCode,
    required this.data
  });

  factory SensorAlerts.fromJSON(Map<String,dynamic> data){
    return SensorAlerts._internal(
        deviceID: data[SensorAlertKeys.deviceID.key],
        timestamp: DateTime.parse(data[SensorAlertKeys.timestamp.key]),
        alertCode: data[SensorAlertKeys.alertCode.key],
        data: data[SensorAlertKeys.data.key]
    );
  }

  Map<String,dynamic> toJson() => {
    SensorAlertKeys.deviceID.key : deviceID,
    SensorAlertKeys.timestamp.key : timestamp.toIso8601String(),
    SensorAlertKeys.alertCode.key : alertCode,
    SensorAlertKeys.data.key : data,
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