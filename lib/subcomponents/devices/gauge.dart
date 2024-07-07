import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class RadialGauge extends StatefulWidget {
  const RadialGauge({super.key, required this.title, required this.value, required this.scale});

  final String title;
  final double value;
  final double scale;

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
          radiusFactor: 0.95,
          showTicks: false,
          showLabels: false,
          startAngle: 135,
          endAngle: 45,
          minimum: 0,
          maximum: 100,
          pointers: [
            RangePointer(
              value: widget.value,
              cornerStyle: CornerStyle.bothCurve,
              width: 8,
              color: generateColor(widget.value, widget.scale),
            )
          ],
          annotations: [
            GaugeAnnotation(
              positionFactor: 0,
              widget: RichText(
                text: TextSpan(
                  text: widget.value.toString(),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 30
                  ),
                  children: const [
                    TextSpan(
                      text: '%',
                      style: TextStyle(
                        fontSize: 17
                      )
                    )
                  ],
                ),
              )
            ),
            GaugeAnnotation(
              angle: 90,
              positionFactor: 0.8,
              widget: Text(
                widget.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  fontFamily: 'Inter',
                ),
              ),
            )
          ],
        )
      ],
    );
  }
}

MaterialColor generateColor(double value, double scale) {

  double percent = (value / scale) * 100;
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