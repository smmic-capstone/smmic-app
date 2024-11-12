import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smmic/models/device_data_models.dart';
import 'package:smmic/providers/devices_provider.dart';
import 'package:smmic/services/devices_services.dart';
import 'package:smmic/sqlitedb/db.dart';
import 'package:smmic/subcomponents/devices/device_dialog.dart';
import 'package:smmic/utils/datetime_formatting.dart';
import 'package:smmic/subcomponents/devices/battery_level.dart';
import 'package:smmic/subcomponents/devices/gauge.dart';

class SensorNodeCardExpanded extends StatefulWidget {
  const SensorNodeCardExpanded({
    super.key,
    required this.deviceID,
    this.snapshot,
    required this.streamController
  });

  final SensorNodeSnapshot? snapshot;
  final String deviceID;
  final Stream<SensorNodeSnapshot> streamController;


  @override
  State<SensorNodeCardExpanded> createState() => _SensorNodeCardExpandedState();
}

class _SensorNodeCardExpandedState extends State<SensorNodeCardExpanded> {
  final DateTimeFormatting _dateTimeFormatting = DateTimeFormatting();

  @override
  Widget build(BuildContext context) {

    SensorNodeSnapshot deviceSnapshot = context.watch<DevicesProvider>().sensorNodeSnapshotMap[widget.deviceID]
        ?? SensorNodeSnapshot.placeHolder(deviceId: widget.deviceID);

    double height = MediaQuery.sizeOf(context).height;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      height: 450,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(15)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                spreadRadius: 0,
                blurRadius: 4,
                offset: Offset(0, 4)
            )
          ]
      ),
      child: Column(
        children: [
          Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const BatteryLevel(
                        batteryLevel: 11.0,
                        alignmentAdjust: 1,
                        shrinkPercentSign: false
                    ),
                    Text(
                        _dateTimeFormatting.formatTime(widget.snapshot == null ? DateTime.now() : widget.snapshot!.timestamp),
                        style: const TextStyle(fontFamily: 'Inter', fontSize: 20)
                    )
                  ],
                ),
              )
          ),
          Expanded(
            flex: 4,
            child: RadialGauge(
                valueType: 'soilMoisture',
                value: deviceSnapshot.soilMoisture,
                limit: 100,
                scaleMultiplier: 1.5
            ),
          ),
          Expanded(
              flex: 3,
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 160,
                      child: RadialGauge(
                        valueType: 'temperature',
                        value: deviceSnapshot.temperature,
                        limit: 100,
                        radiusMultiplier: 0.9,
                      ),
                    ),
                    SizedBox(
                      width: 160,
                      child: RadialGauge(
                        valueType: 'humidity',
                        value: deviceSnapshot.humidity,
                        limit: 100,
                        radiusMultiplier: 0.9,
                      ),
                    ),
                  ],
                ),
              )
          )
        ],
      )
    );
  }
}
