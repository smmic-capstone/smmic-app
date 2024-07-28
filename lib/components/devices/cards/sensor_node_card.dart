import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smmic/models/device_data_models.dart';
import 'package:smmic/pages/devices_subpages/sensor_node.dart';
import 'package:smmic/subcomponents/devices/battery_level.dart';
import 'package:smmic/subcomponents/devices/device_name.dart';
import 'package:smmic/subcomponents/devices/digital_display.dart';
import 'package:smmic/subcomponents/devices/gauge.dart';

class SensorNodeCard extends StatefulWidget {
  const SensorNodeCard({super.key, required this.deviceData, required this.deviceInfo});

  final SensorNode deviceInfo;
  final SensorNodeSnapshot deviceData;

  @override
  State<SensorNodeCard> createState() => _SensorNodeCardState();
}

class _SensorNodeCardState extends State<SensorNodeCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) {
        return SensorNodePage(deviceID: widget.deviceData.deviceID, deviceName: widget.deviceInfo.deviceName);
      })),
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
                    flex: 4,
                    child: Column(
                      children: [
                        Expanded(
                            flex: 3,
                            child: DeviceName(deviceName: widget.deviceInfo.deviceName)
                        ),
                        Expanded(
                          flex: 1,
                          child: BatteryLevel(batteryLevel: widget.deviceData.batteryLevel.toInt()),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                      flex: 10,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                DigitalDisplay(
                                  value: widget.deviceData.temperature,
                                  valueType: 'temperature',
                                ),
                                DigitalDisplay(
                                  value: widget.deviceData.humidity,
                                  valueType: 'humidity',
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Container(
                                alignment: Alignment.center,
                                child: RadialGauge(
                                    valueType: 'soilMoisture',
                                    value: widget.deviceData.soilMoisture,
                                    limit: 100
                                )
                            ),
                          )
                        ],
                      )
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
