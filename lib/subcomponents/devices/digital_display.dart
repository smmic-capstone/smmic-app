import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:smmic/providers/theme_provider.dart';

enum ValueType {
  temperature,
  humidity,
  soilMoisture
}

class SensorDigitalDisplay extends StatefulWidget {
  const SensorDigitalDisplay({
    super.key,
    required this.value,
    required this.valueType,
    required this.opacityOverride,
    this.valueTextStyle,
    this.symbolTextStyle,
    this.labelTextStyle
  });

  final ValueType valueType;
  final dynamic value;
  final double opacityOverride;

  final TextStyle? valueTextStyle;
  final TextStyle? symbolTextStyle;
  final TextStyle? labelTextStyle;

  @override
  State<SensorDigitalDisplay> createState() => _SensorDigitalDisplayState();
}

class _SensorDigitalDisplayState extends State<SensorDigitalDisplay> {
  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.centerLeft,
        child: Stack(
          children: [
            const SizedBox(width: 70),
            RichText(
              text: TextSpan(
                  text: widget.value.toInt().toString(),
                  style: widget.valueTextStyle ?? TextStyle(
                      fontSize: 32,
                      fontFamily: 'Inter',
                      color: context.watch<UiProvider>().isDark
                          ? Colors.white.withOpacity(widget.opacityOverride)
                          : Colors.black.withOpacity(widget.opacityOverride)
                  ),
                  children: [
                    TextSpan(
                        text: widget.valueType == ValueType.temperature
                            ? '°C\n'
                            : widget.valueType == ValueType.soilMoisture ||
                            widget.valueType == ValueType.humidity
                            ? '%\n'
                            : '?\n',
                        style: widget.labelTextStyle ?? TextStyle(
                            fontSize: 18,
                            fontFamily: 'Inter',
                            color: context.watch<UiProvider>().isDark
                                ? Colors.white.withOpacity(widget.opacityOverride)
                                : Colors.black.withOpacity(widget.opacityOverride))
                    ),
                    TextSpan(
                        text: widget.valueType == ValueType.soilMoisture
                            ? 'Soil Moisture'
                            : widget.valueType == ValueType.temperature
                            ? 'Temperature'
                            : widget.valueType == ValueType.humidity
                            ? 'Humidity'
                            : 'Unknown',
                        style: widget.symbolTextStyle ?? TextStyle(
                            fontSize: 9,
                            fontFamily: 'Inter',
                            color: context.watch<UiProvider>().isDark
                                ? Colors.white.withOpacity(widget.opacityOverride)
                                : Colors.black.withOpacity(widget.opacityOverride))
                    )
                  ]
              ),
            ),
            // Positioned(
            //   right: 0,
            //   child: SvgPicture.asset(
            //     widget.valueType == ValueType.temperature
            //         ? 'assets/icons/sun.svg'
            //         : 'assets/icons/wind.svg',
            //     height: 12.5,
            //     width: 12.5,
            //   ),
            // )
          ],
        )
    );
  }
}
