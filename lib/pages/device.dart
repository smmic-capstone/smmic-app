import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smmic/components/devices/details_card.dart';

class Device extends StatefulWidget {
  const Device({super.key, required this.deviceName});

  final String deviceName;

  @override
  State<StatefulWidget> createState() => _DeviceState();
}

class _DeviceState extends State<Device> {

  @override
  Widget build(BuildContext context) {
    Color? bgColor = const Color.fromRGBO(239, 239, 239, 1.0);
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
            icon: Icon(Icons.edit_outlined, size: 21, color: Colors.black,),
          ),
        ],
      ),
      body: const SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DetailsCard()
          ],
        ),
      ),
    );
  }
}