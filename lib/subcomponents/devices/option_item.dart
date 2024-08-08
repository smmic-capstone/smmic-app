import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smmic/models/device_data_models.dart';
import 'package:smmic/providers/device_settings_provider.dart';

class OptionItem extends StatefulWidget {
  const OptionItem({super.key, required this.title, required this.subtitle, required this.condition, required this.logic, required this.enabledConditions});

  final String condition;
  final bool Function(Device) logic;
  final List<String> enabledConditions;
  final String title;
  final String subtitle;

  @override
  State<OptionItem> createState() => _OptionItemState();
}

class _OptionItemState extends State<OptionItem>{
  bool switchValue = false;

  @override
  void initState() {
    switchValue = widget.enabledConditions.contains(widget.condition);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 30),
      title: Text(widget.title),
      subtitle: Text(widget.subtitle),
      trailing: Switch(
        value: switchValue,
        onChanged: (bool option) {
          if(widget.enabledConditions.contains(widget.condition)) {
            context.read<DeviceListOptionsNotifier>().disable(widget.condition);
          } else {
            context.read<DeviceListOptionsNotifier>().enable(widget.condition, widget.logic);
          }
          setState(() {
            switchValue = !switchValue;
          });
        }
      ),
      // trailing: CupertinoSwitch(
      //     value: switchValue,
      //     onChanged: (bool vewValue) {
      //       if(widget.enabledConditions.contains(widget.condition)) {
      //         context.read<DeviceListOptionsNotifier>().disable(widget.condition);
      //       } else {
      //         context.read<DeviceListOptionsNotifier>().enable(widget.condition, widget.logic);
      //       }
      //       setState(() {
      //         switchValue = !switchValue;
      //       });
      //     }),
    );
  }
}