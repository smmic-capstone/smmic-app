import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:smmic/providers/devices_providers.dart';
import 'package:smmic/subcomponents/devices/option_item.dart';
import 'package:provider/provider.dart';

class BottomDrawerButton extends StatefulWidget {
  const BottomDrawerButton({super.key});

  @override
  State<BottomDrawerButton> createState() => _BottomDrawerButtonState();
}

class _BottomDrawerButtonState extends State<BottomDrawerButton> {
  bool viewSensors = false;
  final DeviceListOptionsNotifier _deviceListOptionsNotifier = DeviceListOptionsNotifier();

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
          List<String> enabledConditions = context.watch<DeviceListOptionsNotifier>().enabledConditions.keys.toList();
          return Container(
            alignment: Alignment.topCenter,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(16))
            ),
            height: 320,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Options', style: TextStyle(fontSize: 17))),
                OptionItem(
                  title: 'Sensor Nodes',
                  subtitle: 'Show all Sensor Nodes',
                  condition: 'showSensors',
                  logic: _deviceListOptionsNotifier.showSensors,
                  enabledConditions: enabledConditions,
                ),
                OptionItem(
                  title: 'Sink Nodes',
                  subtitle: 'Show all Sink Nodes',
                  condition: 'showSinks',
                  logic: _deviceListOptionsNotifier.showSinks,
                  enabledConditions: enabledConditions
                ),
                OptionItem(
                  title: 'Color Code',
                  subtitle: 'Color code Devices that belong to the same Sink Node',
                  condition: 'none',
                  logic: _deviceListOptionsNotifier.dummyCondition,
                  enabledConditions: enabledConditions,
                )
              ],
            ),
          );
        }
    );
  }
}