import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smmic/components/devices/device_card.dart';

class Devices extends StatefulWidget {
  const Devices({super.key});

  @override
  State<Devices> createState() => _Devices();
}

class _Devices extends State<Devices> {

  //TODO: assign theme
  Color? bgColor = Color.fromRGBO(239, 239, 239, 100);

  final List<Map<String, dynamic>> devices = [
    {
      'id' : 'SIqokAO1BQBHyJVK',
      'deviceName' : 'SINK NODE',
      'batteryLevel' : 71,
    },
    {
      'id' : 'SEqokAO1BQBHyJVK',
      'deviceName' : 'DEVICE 101',
      'batteryLevel' : 69,
      'soilMoisture' : 65,
      'temperature' : 23,
      'humidity' : 62,
      'timeStamp' : DateTime.now()
    },
    {
      'id' : 'SEx0e9bmweebii5y',
      'deviceName' : 'DEVICE 102',
      'batteryLevel' : 64,
      'soilMoisture' : 17,
      'temperature' : 24,
      'humidity' : 45,
      'timeStamp' : DateTime.now()
    }
  ];

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: const Text('Devices'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(top: 15),
        itemCount: devices.length,
        itemBuilder: (BuildContext context, int index) {
          return DeviceCard(deviceData: devices[index]);
        },
      )
    );
  }

}