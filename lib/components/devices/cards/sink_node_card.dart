import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:smmic/models/device_data_models.dart';
import 'package:smmic/pages/devices_subpages/sensor_node_subpage.dart';
import 'package:smmic/subcomponents/devices/battery_level.dart';
import 'package:smmic/subcomponents/devices/device_name.dart';

class SinkNodeCard extends StatefulWidget {
  const SinkNodeCard({super.key, required this.deviceInfo});

  final SinkNode deviceInfo;

  @override
  State<SinkNodeCard> createState() => _SinkNodeCardState();
}

class _SinkNodeCardState extends State<SinkNodeCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //TODO: IMPLEMENT ON TAP FUNCTION
      // onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) {
      //   return SinkNode(deviceID: widget.deviceData.deviceID, deviceName: widget.deviceData.deviceName);
      // })),
      child: Stack(
        children: [
          Container(
              margin: const EdgeInsets.only(left: 25, right: 25, bottom: 15),
              padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 18),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        spreadRadius: 0,
                        blurRadius: 4,
                        offset: const Offset(0, 4)
                    )
                  ]
              ),
              height: 160,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        Expanded(
                            flex: 3,
                            child: DeviceName(deviceName: '${widget.deviceInfo.deviceName.substring(0, 5)}...')
                           ),
                        Expanded(
                            flex: 1,
                            //TODO: add snapshot data here
                            child: BatteryLevel(batteryLevel: 00)
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(),
                  ),
                ],
              )
          ),
          Container(
            padding: const EdgeInsets.only(right: 37, top: 12),
            alignment: Alignment.topRight,
            child: RotatedBox(
              quarterTurns: 2,
              child: Icon(
                CupertinoIcons.arrow_down_left_circle,
                size: 20,
                color: Colors.black.withOpacity(0.25),
              ),
            ),
          )
        ],
      ),
    );
  }
}