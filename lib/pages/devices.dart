import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smmic/components/devices/cards/sensor_node_card.dart';
import 'package:smmic/components/devices/cards/sink_node_card.dart';
import 'package:smmic/models/devices/sensor_node_data_model.dart';
import 'package:smmic/pages/sensor_node.dart';
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
    // double height = MediaQuery.sizeOf(context).height;
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: const Text('Devices'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: _filterCards(_buildCards(_userDataServices.getSinkNodes())),
      ),
    );
  }

  List<Widget> _filterCards(List<Widget> cards) {

    //TODO: IMPLEMENT FILTER FUNCTION
    // List<Widget> filteredCards = cards.whereType<SensorNodeCard>().toList();

    return cards;

  }

  List<Widget> _buildCards(List<String> sinkNodesList) {
    List<Widget> cards = sinkNodesList.expand((sinkNodeID) {
      List<String> sensorNodesList = UserDataServices().getSensorNodes(sinkNodeID);
      List<Widget> widgets = [
        SinkNodeCard(deviceData: _sinkNodeDataServices.getSnapshot(sinkNodeID)),
        ...sensorNodesList.map((sensorNodeID) {
          return SensorNodeCard(deviceData: _sensorNodeDataServices.getSnapshot(sensorNodeID));
        })
      ];
      return widgets;
    }).toList();

    return cards;
  }
}
