import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smmic/components/devices/chart.dart';
import 'package:smmic/components/devices/cards_expanded/sensor_node_card_expanded.dart';

class SensorNodePage extends StatefulWidget {
  const SensorNodePage({super.key, required this.deviceID, required this.deviceName});

  final String deviceID;
  final String deviceName;

  @override
  State<StatefulWidget> createState() => _SensorNodePageState();
}

class _SensorNodePageState extends State<SensorNodePage> {

  @override
  Widget build(BuildContext context) {
    Color? bgColor = Color.fromRGBO(239, 239, 239, 1.0);
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: Text(widget.deviceName),
        centerTitle: true,
        actions: [
          IconButton(
            padding: EdgeInsets.all(19),
            onPressed: () => {},
            icon: Icon(Icons.edit_outlined, size: 21, color: Colors.black),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SensorNodeCardExpanded(deviceID: widget.deviceID),
            LineChart(deviceID: widget.deviceID),
          ],
        ),
      ),
    );
  }
}