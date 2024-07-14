import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Irrigation extends StatefulWidget {
  const Irrigation({super.key});

  @override
  State<Irrigation> createState() => _IrrigationState();
}

class _IrrigationState extends State<Irrigation> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Irrigation'),
      ),
    );
  }
}
