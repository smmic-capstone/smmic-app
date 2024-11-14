import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:provider/provider.dart';
import 'package:smmic/providers/theme_provider.dart';

class DigitalDisplay extends StatefulWidget {
  const DigitalDisplay({
    super.key,
    required this.value,
    required this.valueType,
    required this.opacityOverride
  });

  final String valueType;
  final dynamic value;
  final double opacityOverride;

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
                    ? Colors.white.withOpacity(0.15)
                    : Colors.black.withOpacity(0.15))),
        height: 53,
        width: 73,
        child: Stack(
          children: [
            // Align(
            //   alignment: Alignment.topRight,
            //   child: Padding(
            //     padding: const EdgeInsets.only(right: 6, top: 2.5),
            //     child: Icon(
            //       CupertinoIcons.arrow_down_circle,
            //       size: 12,
            //       color: Colors.deepOrange.withOpacity(0.8),
            //     ),
            //   )
            // ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  text: TextSpan(
                      text: widget.value.toInt().toString(),
                      style: TextStyle(
                          fontSize: 24,
                          fontFamily: 'Inter',
                          color: context.watch<UiProvider>().isDark
                              ? Colors.white.withOpacity(widget.opacityOverride)
                              : Colors.black.withOpacity(widget.opacityOverride)),
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
                                    ? Colors.white.withOpacity(widget.opacityOverride)
                                    : Colors.black.withOpacity(widget.opacityOverride))
                        ),
                        TextSpan(
                            text: widget.valueType == 'soil moisture'
                                ? 'Soil Moisture'
                                : widget.valueType == 'temperature'
                                ? 'Temperature'
                                : widget.valueType == 'humidity'
                                ? 'Humidity'
                                : 'Unknown',
                            style: TextStyle(
                                fontSize: 9,
                                fontFamily: 'Inter',
                                color: context.watch<UiProvider>().isDark
                                    ? Colors.white.withOpacity(widget.opacityOverride)
                                    : Colors.black.withOpacity(widget.opacityOverride))
                        )
                      ]),
                ),
              ],
            )
          ],
        )
    );
  }
}
