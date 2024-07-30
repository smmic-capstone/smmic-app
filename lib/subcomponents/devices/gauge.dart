import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class RadialGauge extends StatefulWidget {
  const RadialGauge({super.key, required this.valueType, required this.value, required this.limit, this.scaleMultiplier = 1, this.radiusMultiplier = 1});

  final String valueType;
  final double value;
  final double limit;
  final double scaleMultiplier;
  final double radiusMultiplier;

  @override
  State<StatefulWidget> createState() => _RadialGaugeState();
}

class _RadialGaugeState extends State<RadialGauge>{
  @override
  Widget build(BuildContext context) {
    return SfRadialGauge(
      axes: <RadialAxis>[
        RadialAxis(
          axisLineStyle: const AxisLineStyle(
            color: Color.fromRGBO(216, 216, 216, 1),
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
              color: setColor(widget.value, widget.limit),
            )
          ],
          annotations: [
            GaugeAnnotation(
              positionFactor: 0,
              widget: RichText(
                text: TextSpan(
                  text: widget.value.toInt().toString(),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 30 * widget.scaleMultiplier,
                    color: Colors.black
                  ),
                  children: [
                    TextSpan(
                      text: setSymbol(widget.valueType),
                      style: TextStyle(
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
                  style: TextStyle(
                    fontSize: 10 * (!(widget.scaleMultiplier == 1) ? widget.scaleMultiplier * 0.9 : 1),
                    fontFamily: 'Inter',
                    color: Colors.black
                  ),
                ),
              )
            )
          ],
        )
      ],
    );
  }
}

String setSymbol(String type) {
  switch(type) {
    case == 'soilMoisture' || 'humidity':
      return '%';
    case == 'temperature':
      return '°C';
    default:
      return '$type: unknown type (sm, tm, hm)';
  }
}

String setTitle(String type) {
  switch(type) {
    case == 'soilMoisture':
      return 'Soil\nMoisture';
    case == 'temperature':
      return 'Temp.';
    case == 'humidity':
      return 'Humidity';
    default:
      return '$type: unknown type (sm, tm, hm)';
  }
}

MaterialColor setColor(double value, double limit) {

  double percent = (value / limit) * 100;
  MaterialColor? color;

  switch (percent) {
    case <= 15:
      color = Colors.red;
      break;
    case > 15 && <= 25:
      color = Colors.orange;
      break;
    case > 25 && <= 50:
      color = Colors.lime;
      break;
    case > 50 && <= 75:
      color = Colors.lightGreen;
      break;
    case > 75 && <= 100:
      color = Colors.green;
      break;
  }

  return color!;
}