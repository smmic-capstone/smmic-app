import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smmic/components/devices/cards/sensor_node_card.dart';
import 'package:smmic/components/devices/cards/sink_node_card.dart';
import 'package:smmic/models/devices/sensor_node_data_model.dart';
import 'package:smmic/pages/sensor_node.dart';
import 'package:smmic/services/devices/sensor_node_data_services.dart';
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

  @override
  Widget build(BuildContext context) {
    // double height = MediaQuery.sizeOf(context).height;
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: const Text('Devices'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      //TODO: change this into a tab view, where one tab lists all sink nodes and another tab lists all sensor nodes
      body: ListView.builder(
        padding: const EdgeInsets.only(top: 15),
        itemCount: _userDataServices.getSensorNodes().length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            child: SensorNodeCard(deviceData: _sensorNodeDataServices.getSnapshot(_userDataServices.getSensorNodes()[index])),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) {
              return SensorNode(deviceID: _userDataServices.getSensorNodes()[index], deviceName: _sensorNodeDataServices.getSnapshot(_userDataServices.getSensorNodes()[index]).deviceName);
            })),
          );
        },
      )
    );
  }
}
