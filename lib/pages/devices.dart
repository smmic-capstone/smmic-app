import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smmic/components/devices/cards/sensor_node_card.dart';
import 'package:smmic/components/devices/cards/sink_node_card.dart';
import 'package:smmic/components/devices/bottom_drawer.dart';
import 'package:smmic/models/device_data_models.dart';
import 'package:smmic/providers/device_settings_provider.dart';
import 'package:smmic/providers/devices_provider.dart';
import 'package:smmic/services/devices_services.dart';
import 'package:smmic/services/user_data_services.dart';
import 'package:smmic/utils/logs.dart';

class Devices extends StatefulWidget {
  const Devices({super.key});

  @override
  State<Devices> createState() => _Devices();
}

class _Devices extends State<Devices> {
  final Logs _logs = Logs(tag: 'devices.dart');


  Color? bgColor = const Color.fromRGBO(239, 239, 239, 1.0);
  final UserDataServices _userDataServices = UserDataServices();
  final DevicesServices _devicesServices = DevicesServices();

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
            padding: EdgeInsets.only(right: 10),
            child: BottomDrawerButton(),
          )
        ],
      ),
      body: ListView(
        children: [
          ..._buildCards(
              sinkNodeList: context.watch<DevicesProvider>().sinkNodeList,
              sensorNodeList: context.watch<DevicesProvider>().sensorNodeList,
              options: context.watch<DeviceListOptionsNotifier>().enabledConditions
          ),
        ],
      )
    );
  }

  List<Widget> _buildCards({required List<SinkNode> sinkNodeList, required List<SensorNode> sensorNodeList, required Map<String, bool Function(Widget)> options}){
    List<Widget> cards = [];

    for(int i = 0; i < sinkNodeList.length; i++){
      cards.add(SinkNodeCard(deviceInfo: sinkNodeList[i]));
      //List<SensorNode> sensorGroup = sensorNodeList.where((item) => item.registeredSinkNode == sinkNodeList[i].deviceID).toList();
      for(int x = 0; x < sensorNodeList.length; x++){
        if (sensorNodeList[x].registeredSinkNode == sinkNodeList[i].deviceID){
          cards.add(SensorNodeCard(deviceInfo: sensorNodeList[x]));
        }
      }
    }

    return cards.where((card) {
      return options.keys.map((optionKey) => options[optionKey]!(card)).any((result) => result);
    }).toList();
  }

  /*List<Widget> _buildCards(List<SinkNode> sinkNodesList, Map<String, bool Function(Device)> options) {
    return _devices(sinkNodesList, options).map((device) {
      if (device is SinkNode) {
        return SinkNodeCard(deviceInfo: device, deviceData: _devicesServices.getSinkSnapshot(id: device.deviceID));
      }
      if (device is SensorNode) {
        return SensorNodeCard(deviceInfo: device, deviceData: _devicesServices.getSensorSnapshot(id: device.deviceID));
      }
      throw Exception('Type mismatch: ${device.runtimeType.toString()}');
    }).toList();
  }

  List<Device> _devices(List<SinkNode> sinkNodeList, Map<String, bool Function(Device)> options) {
    List<Device> devices = sinkNodeList.expand((sinkNode) {
      List<String> sensorNodesList = sinkNode.registeredSensorNodes;
      List<Device> sensorNodes = [
        sinkNode,
        ...sensorNodesList.map((sensorNodeID) {
          return _devicesServices.getSensorInfo(id: sensorNode);
        })
      ];
      return sensorNodes;
      // returns a list of all items that match the option condition
      // TODO: use flutter isolates for this process
    }).where((device) => options.keys.map((option) => options[option]!(device)).any((result) => result)).toList();
    return devices;
  }*/
}