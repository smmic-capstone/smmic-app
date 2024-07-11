import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Device extends StatefulWidget {
  const Device({super.key, required this.deviceName});

  final String deviceName;

  @override
  State<StatefulWidget> createState() => _DeviceState();
}

class _DeviceState extends State<Device> {

  Color? bgColor = Color.fromRGBO(239, 239, 239, 100);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        leading: Icon(Icons.arrow_back),
        title: Text('device 101'/*widget.deviceName*/),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: () => {},
              icon: Icon(Icons.edit_outlined, size: 21, color: Colors.black,),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(15)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.06), spreadRadius: 0, blurRadius: 4, offset: Offset(0, 4))
                ]
              ),
              height: 375,
              margin: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
            )
          ],
        ),
      ),
    );
  }
}