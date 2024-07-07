import 'package:flutter/material.dart';

class DeviceName extends StatelessWidget {
  const DeviceName({super.key, required this.deviceName});

  final String deviceName;

  @override
  Widget build(BuildContext context){
    return Container(
      padding: EdgeInsets.only(top: 1),
      alignment: Alignment.topLeft,
      child: Text(
          deviceName,
          style: const TextStyle(
              fontSize: 20,
              fontFamily: 'Inter',
              height: 1.1
          )
      ),
    );
  }
}