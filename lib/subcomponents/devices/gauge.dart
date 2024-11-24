import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smmic/providers/theme_provider.dart';
import 'package:smmic/subcomponents/devices/digital_display.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class RadialGauge extends StatefulWidget {
  const RadialGauge({
    super.key,
    required this.valueType,
    required this.value,
    required this.limit,
    required this.opacity,
    this.scaleMultiplier = 1,
    this.radiusMultiplier = 1,
    this.valueTextStyle,
    this.symbolTextStyle,
    this.labelTextStyle
  });

  final ValueType valueType;
  final double opacity;
  final double value;
  final double limit;
  final double scaleMultiplier;
  final double radiusMultiplier;
  final TextStyle? valueTextStyle;
  final TextStyle? symbolTextStyle;
  final TextStyle? labelTextStyle;

  @override
  State<StatefulWidget> createState() => _RadialGaugeState();
}

class _RadialGaugeState extends State<RadialGauge> {

  @override
  Widget build(BuildContext context) {
    return SfRadialGauge(
      axes: <RadialAxis>[
        RadialAxis(
          axisLineStyle: AxisLineStyle(
            color: context.watch<UiProvider>().isDark
                ? Colors.white.withOpacity(0.10)
                : Colors.black.withOpacity(0.10),
            cornerStyle: CornerStyle.bothCurve,
            thickness: 8,
          ),
          radiusFactor: 0.95 * widget.radiusMultiplier,
          showTicks: false,
          showLabels: false,
          startAngle: 135,
          endAngle: 45,
          minimum: 0,
          maximum: widget.limit,
          pointers: [
            RangePointer(
              value: widget.value,
              cornerStyle: CornerStyle.bothCurve,
              width: 8,
              color: setColor(widget.value, widget.limit, widget.opacity),
            )
          ],
          annotations: [
            GaugeAnnotation(
                positionFactor: 0,
                widget: RichText(
                  text: TextSpan(
                    text: widget.value.toInt().toString(),
                    style: widget.valueTextStyle ?? TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 30 * widget.scaleMultiplier,
                        color: context.watch<UiProvider>().isDark
                            ? Colors.white.withOpacity(widget.opacity)
                            : Colors.black.withOpacity(widget.opacity)
                    ),
                    children: [
                      TextSpan(
                          text: setSymbol(widget.valueType),
                          style: widget.symbolTextStyle ?? TextStyle(
                              fontSize: 17 * widget.scaleMultiplier
                          )
                      )
                    ],
                  ),
                )
            ),
            GaugeAnnotation(
                angle: 90,
                positionFactor: 0.8,
                widget: SizedBox(
                  child: Text(
                    setTitle(widget.valueType),
                    textAlign: TextAlign.center,
                    style: widget.labelTextStyle ?? TextStyle(
                        fontSize: 10 *
                            (!(widget.scaleMultiplier == 1)
                                ? widget.scaleMultiplier * 0.9
                                : 1),
                        fontFamily: 'Inter',
                        color: context.watch<UiProvider>().isDark
                            ? Colors.white.withOpacity(widget.opacity)
                            : Colors.black.withOpacity(widget.opacity)
                    ),
                  ),
                ))
          ],
        )
      ],
    );
  }
}

String setSymbol(ValueType type) {
  switch (type) {
    case == ValueType.soilMoisture || ValueType.humidity:
      return '%';
    case == ValueType.temperature:
      return '°C';
    default:
      return '$type: unknown type (sm, tm, hm)';
  }
}

String setTitle(ValueType type) {
  switch (type) {
    case == ValueType.soilMoisture:
      return 'Soil\nMoisture';
    case == ValueType.temperature:
      return 'Temp.';
    case == ValueType.humidity:
      return 'Humidity';
    default:
      return '$type: unknown type (sm, tm, hm)';
  }
}

Color setColor(double value, double limit, double opacity) {
  double percent = (value / limit) * 100;
  Color color = Colors.grey;
  switch (percent) {
    case <= 15:
      color = Colors.red.withOpacity(opacity);
      break;
    case > 15 && <= 25:
      color = Colors.orange.withOpacity(opacity);
      break;
    case > 25 && <= 50:
      color = Colors.lime.withOpacity(opacity);
      break;
    case > 50 && <= 75:
      color = Colors.lightGreen.withOpacity(opacity);
      break;
    case > 75 && <= 100:
      color = Colors.green.withOpacity(opacity);
      break;
  }

  return color;
}
