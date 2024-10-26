import 'package:flutter/material.dart';
import 'package:smmic/pages/devices.dart';

class PreloadDevices extends StatelessWidget {
  const PreloadDevices({super.key});

  @override
  Widget build(BuildContext context){
    return const Offstage(
      offstage: true,
      child: Devices(),
    );
  }
}