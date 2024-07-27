import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:smmic/pages/devices.dart';
import 'package:smmic/subcomponents/devices/drawer_option.dart';

class BottomDrawerButton extends StatefulWidget {
  const BottomDrawerButton({super.key});

  @override
  State<BottomDrawerButton> createState() => _BottomDrawerButtonState();
}

class _BottomDrawerButtonState extends State<BottomDrawerButton> {
  bool viewSensors = false;

  @override
  Widget build(BuildContext context) {
    return Builder(
        builder: (context) {
          return IconButton(
              onPressed: () {
                _openBottomSheet(context);
                },
              icon: const Icon(Icons.settings)
          );
        });
  }

  void _openBottomSheet(BuildContext context) {
    showModalBottomSheet(
        enableDrag: true,
        context: context,
        builder: (context) {
          return Container(
            alignment: Alignment.topCenter,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(16))
            ),
            height: 320,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Options', style: TextStyle(fontSize: 17))),
                OptionItem(title: 'Sensor Nodes', subtitle: 'Show all Sensor Nodes', defaultValue: true),
                OptionItem(title: 'Sink Nodes', subtitle: 'Show all Sink Nodes', defaultValue: true),
                OptionItem(title: 'Color Code', subtitle: 'Color code Devices that belong to the same Sink Node', defaultValue: false)
              ],
            ),
          );
        }
    );
  }
}