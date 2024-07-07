import 'package:flutter/cupertino.dart';

class BatteryLevel extends StatefulWidget {
  final int batteryLevel;
  const BatteryLevel({super.key, required this.batteryLevel});

  @override
  State<BatteryLevel> createState() => _BatteryLevelState();
}

class _BatteryLevelState extends State<BatteryLevel> {

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomLeft,
      child: Row(
        children: [
          const Icon(CupertinoIcons.battery_75_percent, size: 36, fill: 0),
          Container(
            padding: const EdgeInsets.only(top:5.5),
            child: Padding(
              padding: const EdgeInsets.only(left: 7),
              child: RichText(
                  text: TextSpan(
                      text: widget.batteryLevel.toString(),
                      style: const TextStyle(fontSize: 20, fontFamily: 'Inter'),
                      children: const [
                        TextSpan(
                            text: '%',
                            style: TextStyle(fontSize: 13)
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