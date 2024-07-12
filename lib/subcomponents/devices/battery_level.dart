import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BatteryLevel extends StatefulWidget {
  final int batteryLevel;
  /// Vertical alignment of battery level value relative to the battery icon. Default value is 5.5
  final double alignmentAdjust;
  final bool shrinkPercentSign;
  const BatteryLevel({super.key, required this.batteryLevel, this.alignmentAdjust = 5.5, this.shrinkPercentSign = true});

  @override
  State<BatteryLevel> createState() => _BatteryLevelState();
}

class _BatteryLevelState extends State<BatteryLevel> {

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          const Icon(CupertinoIcons.battery_75_percent, size: 36, fill: 0),
          Container(
            padding: EdgeInsets.only(top: widget.alignmentAdjust),
            child: Padding(
              padding: const EdgeInsets.only(left: 7),
              child: RichText(
                  text: TextSpan(
                      text: widget.batteryLevel.toString(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontFamily: 'Inter',
                        color: Colors.black
                      ),
                      children: [
                        TextSpan(
                            text: '%',
                            style: TextStyle(fontSize: widget.shrinkPercentSign ? 13 : 20)
                        )
                      ]
                  )
              ),
            ),
          )
        ],
      ),
    );
  }
}