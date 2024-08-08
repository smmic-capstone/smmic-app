library devices_services;

import 'package:smmic/models/device_data_models.dart';
import 'package:smmic/services/user_data_services.dart';

part 'devices/sensor_data.dart';
part 'devices/sink_data.dart';

class DevicesServices {
  final _SensorNodeDataServices _sensorNodeDataServices = _SensorNodeDataServices();
  final _SinkNodeDataServices _sinkNodeDataServices = _SinkNodeDataServices();

  /// Returns sensor node information (`deviceID`, `deviceName`, `coordinates`, `registeredSinkNode`)
  SensorNode getSensorInfo({required String id}){
    return _sensorNodeDataServices.getInfo(id);
  }

  /// Returns sensor node snapshot data (`deviceID`, `timestamp`, `soilMoisture`, `temperature`, `humidity`, `batteryLevel`)
  SensorNodeSnapshot getSensorSnapshot({required String id}) {
    return _sensorNodeDataServices.getSnapshot(id);
  }

  /// Returns sink node information (`deviceID`, `deviceName`, `coordinates`, `registeredSinkNode`)
  SinkNode getSinkInfo({required String id}){
    return _sinkNodeDataServices.getInfo(id);
  }

  /// Returns sink node snapshot data (`deviceID`, `batteryLevel`)
  SinkNodeSnapshot getSinkSnapshot({required String id}){
    return _sinkNodeDataServices.getSnapshot(id);
  }

  List<SensorNodeSnapshot> getSensorTimeSeries({required String id}){
    return _sensorNodeDataServices.getTimeSeries(id);
  }
}