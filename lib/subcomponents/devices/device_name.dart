import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smmic/providers/theme_provider.dart';

class DeviceName extends StatelessWidget {
  const DeviceName({super.key, required this.deviceName});

  final String deviceName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 1),
      alignment: Alignment.topLeft,
      child: Text(deviceName,
          style: TextStyle(
              fontSize: 24,
              fontFamily: 'Inter',
              height: 1.1,
              color: context.watch<UiProvider>().isDark
                  ? Colors.white
                  : Colors.black)),
    );
  }
}
