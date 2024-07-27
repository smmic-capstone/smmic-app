import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class OptionItem extends StatefulWidget {
  const OptionItem({super.key, required this.title, required this.subtitle, required this.defaultValue});

  final String title;
  final String subtitle;
  final bool defaultValue;

  @override
  State<OptionItem> createState() => _OptionItemState();
}

class _OptionItemState extends State<OptionItem>{
  bool switchValue = false;

  @override
  void initState() {
    switchValue = widget.defaultValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 30),
      title: Text(widget.title),
      subtitle: Text(widget.subtitle),
      trailing: CupertinoSwitch(
          value: switchValue,
          onChanged: (bool vewValue) {
            setState(() {
              switchValue = !switchValue;
            });
          }),
    );
  }
}