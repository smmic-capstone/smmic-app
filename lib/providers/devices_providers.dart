import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smmic/models/device_data_models.dart';

class DeviceListOptionsNotifier extends ChangeNotifier {
  //TODO: Implement Device List Options ChangeNotifier
  Map<String, bool Function(Device)> _enabledConditions = {
    'showSensors' : (Device device) => device is SensorNode,
    'showSinks' : (Device device) => device is SinkNode
  };

  Map<String, bool Function(Device)> get enabledConditions => _enabledConditions;

  bool Function(Device) showSensors = (Device device) => device is SensorNode;
  bool Function(Device) showSinks = (Device device) => device is SinkNode;
  bool Function(Device) dummyCondition = (Device device) => !(device is Device);

  void enable(String condition, bool Function(Device) logic) {
    if(!_enabledConditions.containsKey(condition)){
      _enabledConditions.addAll({condition: logic});
    }
    notifyListeners();
  }

  void disable(String condition) {
    if(_enabledConditions.containsKey(condition)){
      _enabledConditions.remove(condition);
      notifyListeners();
    }
    notifyListeners();
  }
}

class DeviceOptionsNotifier extends ChangeNotifier {
  //TODO: Implement Device Options ChangeNotifier

}