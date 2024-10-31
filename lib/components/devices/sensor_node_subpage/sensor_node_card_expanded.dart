import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smmic/models/device_data_models.dart';
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

  SensorNodeSnapshot? cardReadings;
  SensorNodeSnapshot? sqlCardReadings;

  @override
  Widget build(BuildContext context) {
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
      child: FutureBuilder(
        future: DatabaseHelper.getAllReadings(widget.deviceID),
        builder: (context, futureSnapshot) {
          sqlCardReadings = futureSnapshot.data;
          return StreamBuilder<SensorNodeSnapshot>(
            stream: widget.streamController,
            builder: (context, readingsSnapshot) {
              if(readingsSnapshot.hasData && readingsSnapshot.data?.deviceID == widget.deviceID){
                cardReadings = readingsSnapshot.data;
              }
              final batteryLevel = cardReadings?.batteryLevel ?? sqlCardReadings?.batteryLevel ?? 00;
              final humidity = cardReadings?.humidity ?? sqlCardReadings?.humidity ?? 00;
              final temperature = cardReadings?.temperature ?? sqlCardReadings?.temperature ?? 00;
              final soilMoisture = cardReadings?.soilMoisture ?? sqlCardReadings?.soilMoisture ?? 00;
              return Column(
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
                        value: soilMoisture,
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
                                value: temperature,
                                limit: 100,
                                radiusMultiplier: 0.9,
                              ),
                            ),
                            SizedBox(
                              width: 160,
                              child: RadialGauge(
                                valueType: 'humidity',
                                value: humidity,
                                limit: 100,
                                radiusMultiplier: 0.9,
                              ),
                            ),
                          ],
                        ),
                      )
                  )
                ],
              );
            }
          );
        }
      ),
    );
  }
}
