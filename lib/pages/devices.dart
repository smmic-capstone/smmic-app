import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smmic/components/devices/cards/sensor_node_card.dart';
import 'package:smmic/components/devices/cards/sink_node_card.dart';
import 'package:smmic/components/devices/options_drawer.dart';
import 'package:smmic/models/device_data_models.dart';
import 'package:smmic/providers/devices_providers.dart';
import 'package:smmic/services/devices/sensor_data.dart';
import 'package:smmic/services/devices/sink_data.dart';
import 'package:smmic/services/user_data_services.dart';

class Devices extends StatefulWidget {
  const Devices({super.key});

  @override
  State<Devices> createState() => _Devices();
}

class _Devices extends State<Devices> {
  Color? bgColor = const Color.fromRGBO(239, 239, 239, 1.0);
  final UserDataServices _userDataServices = UserDataServices();
  final SensorNodeDataServices _sensorNodeDataServices = SensorNodeDataServices();
  final SinkNodeDataServices _sinkNodeDataServices = SinkNodeDataServices();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: const Text('Devices'),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: BottomDrawerButton(),
          )
        ],
      ),
      body: ListView(
        children: [
          ..._buildCards(_userDataServices.getSinkNodes(), context.watch<DeviceListOptionsNotifier>().enabledConditions),
        ],
      )
    );
  }

  List<Widget> _buildCards(List<String> sinkNodesList, Map<String, bool Function(Device)> options) {
    return _devices(sinkNodesList, options).map((device) {
      if (device is SinkNode) {
        return SinkNodeCard(deviceInfo: device, deviceData: _sinkNodeDataServices.getSnapshot(device.deviceID));
      }
      if (device is SensorNode) {
        return SensorNodeCard(deviceInfo: device, deviceData: _sensorNodeDataServices.getSnapshot(device.deviceID));
      }
      throw Exception('Type mismatch: ${device.runtimeType.toString()}');
    }).toList();
  }

  List<Device> _devices(List<String> sinkNodesIDList, Map<String, bool Function(Device)> options) {
    List<Device> devices = sinkNodesIDList.expand((sinkNodeID) {
      SinkNode sinkNodeInfo = SinkNodeDataServices().getInfo(sinkNodeID);
      List<String> sensorNodesList = sinkNodeInfo.registeredSensorNodes;
      List<Device> sensorNodes = [
        sinkNodeInfo,
        ...sensorNodesList.map((sensorNode) {
          return SensorNodeDataServices().getInfo(sensorNode);
        })
      ];
      return sensorNodes;
    }).where((device) => options.keys.map((option) => options[option]!(device)).any((result) => result)).toList();
    return devices;
  }
}