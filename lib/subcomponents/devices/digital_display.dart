import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smmic/providers/theme_provider.dart';

class DigitalDisplay extends StatefulWidget {
  const DigitalDisplay(
      {super.key, required this.value, required this.valueType});

  final String valueType;
  final dynamic value;

  @override
  State<DigitalDisplay> createState() => _DigitalDisplayState();
}

class _DigitalDisplayState extends State<DigitalDisplay> {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(top: 3, bottom: 5, left: 8),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            border: Border.all(
                color: context.watch<UiProvider>().isDark
                    ? Colors.white
                    : Colors.black)),
        height: 53,
        width: 73,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RichText(
              text: TextSpan(
                  text: widget.value.toInt().toString(),
                  style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'Inter',
                      color: context.watch<UiProvider>().isDark
                          ? Colors.white
                          : Colors.black),
                  children: [
                    TextSpan(
                        text: widget.valueType == 'temperature'
                            ? '°C\n'
                            : widget.valueType == 'soil moisture' ||
                                    widget.valueType == 'humidity'
                                ? '%\n'
                                : '?\n',
                        style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Inter',
                            color: context.watch<UiProvider>().isDark
                                ? Colors.black
                                : Colors.white)),
                    TextSpan(
                        text: widget.valueType == 'soil moisture'
                            ? 'Soil Moisture'
                            : widget.valueType == 'temperature'
                                ? 'Temperature'
                                : widget.valueType == 'humidity'
                                    ? 'Humidity'
                                    : 'Unkown',
                        style: TextStyle(
                            fontSize: 9,
                            fontFamily: 'Inter',
                            color: context.watch<UiProvider>().isDark
                                ? Colors.white
                                : Colors.black))
                  ]),
            ),
          ],
        ));
  }
}
