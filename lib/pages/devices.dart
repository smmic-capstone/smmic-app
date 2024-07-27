import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:smmic/components/devices/cards/sensor_node_card.dart';
import 'package:smmic/components/devices/cards/sink_node_card.dart';
import 'package:smmic/components/devices/drawer.dart';
import 'package:smmic/models/devices/sensor_node_data_model.dart';
import 'package:smmic/models/devices/sink_node_data_model.dart';
import 'package:smmic/services/devices/sensor_node_data_services.dart';
import 'package:smmic/services/devices/sink_node_data_services.dart';
import 'package:smmic/services/user_data_services.dart';

class Devices extends StatefulWidget {
  const Devices({super.key});

  @override
  State<Devices> createState() => _Devices();
}

class _Devices extends State<Devices> {
  late SensorNodeData _sensorNodeSnapshot;

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
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: BottomDrawerButton(),
          )
        ],
      ),
      body: ListView(
        children: [
          ..._buildCards(_userDataServices.getSinkNodes()),
        ],
      ),
    );
  }

  List<Widget> _buildCards(List<String> sinkNodesList) {
    return _devices(UserDataServices().getSinkNodes()).map((device) {
      if (device.type == 'sink') {
        return SinkNodeCard(deviceData: SinkNodeDataServices().getSnapshot(device.deviceID));
      } else {
        return SensorNodeCard(deviceData: SensorNodeDataServices().getSnapshot(device.deviceID));
      }
    }).toList();
  }

  List<Device> _devices(List<String> sinkNodesIDList) {
    List<Device> devices = sinkNodesIDList.expand((sinkNode) {
      SinkNodeData sinkNodeData = SinkNodeDataServices().getSnapshot(sinkNode);
      List<String> sensorNodesIDList = UserDataServices().getSensorNodes(sinkNode);
      List<Device> sensorNodes = [
        Device.named(type: 'sink', deviceID: sinkNodeData.deviceID, deviceName: sinkNodeData.deviceName),
        ...sensorNodesIDList.map((sensorNode) {
          SensorNodeData sensorNodeData = SensorNodeDataServices().getSnapshot(sensorNode);
          return Device.named(type: 'sensor', deviceID: sensorNodeData.deviceID, deviceName: sensorNodeData.deviceName, sinkNodeID: sinkNode);
        })
      ];
      return sensorNodes;
    }).toList();

    return devices;
  }
}

class Device {
  final String type;
  final String deviceID;
  final String deviceName;
  final String sinkNodeID;
  final String coordinates;

  Device.named({required this.type,required this.deviceID, required this.deviceName, this.sinkNodeID = '', this.coordinates = ''});
}

