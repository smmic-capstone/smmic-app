import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smmic/components/devices/device_card.dart';
import 'package:smmic/pages/device.dart';

class Devices extends StatefulWidget {
  const Devices({super.key});

  @override
  State<Devices> createState() => _Devices();
}

class _Devices extends State<Devices> {
  Color? bgColor = const Color.fromRGBO(239, 239, 239, 1.0);
  final List<Map<String, dynamic>> _mockDevicesData = [
    {
      'id': 'SIqokAO1BQBHyJVK',
      'deviceName': 'SINK NODE',
      'batteryLevel': 71,
    },
    {
      'id': 'SEqokAO1BQBHyJVK',
      'deviceName': 'DEVICE 101',
      'batteryLevel': 69,
      'soilMoisture': 65,
      'temperature': 23,
      'humidity': 62,
      'timeStamp': DateTime.now()
    },
    {
      'id': 'SEx0e9bmweebii5y',
      'deviceName': 'DEVICE 102',
      'batteryLevel': 64,
      'soilMoisture': 17,
      'temperature': 24,
      'humidity': 45,
      'timeStamp': DateTime.now()
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
        itemCount: _mockDevicesData.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            child: DeviceCard(deviceData: _mockDevicesData[index]),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Device(deviceName: _mockDevicesData[index]['deviceName']))),
          );
        },
      )
    );
  }
}
