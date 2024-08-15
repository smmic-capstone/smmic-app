import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smmic/components/devices/cards/sensor_node_card.dart';
import 'package:smmic/components/devices/cards/sink_node_card.dart';
import 'package:smmic/models/device_data_models.dart';

class DeviceListOptionsNotifier extends ChangeNotifier {
  //TODO: Implement Device List Options ChangeNotifier
  Map<String, bool Function(Widget)> _enabledConditions = {
    'showSensors' : (Widget card) => card is SensorNodeCard,
    'showSinks' : (Widget card) => card is SinkNodeCard
  };

  Map<String, bool Function(Widget)> get enabledConditions => _enabledConditions;

  bool Function(Widget) showSensors = (Widget card) => card is SensorNodeCard;
  bool Function(Widget) showSinks = (Widget card) => card is SinkNodeCard;
  bool Function(Widget) dummyCondition = (Widget card) => !(card is Widget);

  void enable(String condition, bool Function(Widget) logic) {
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