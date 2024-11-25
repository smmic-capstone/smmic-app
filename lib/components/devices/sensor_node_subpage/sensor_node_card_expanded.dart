import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smmic/models/device_data_models.dart';
import 'package:smmic/providers/connections_provider.dart';
import 'package:smmic/providers/devices_provider.dart';
import 'package:smmic/providers/theme_provider.dart';
import 'package:smmic/services/devices_services.dart';
import 'package:smmic/sqlitedb/db.dart';
import 'package:smmic/subcomponents/devices/device_dialog.dart';
import 'package:smmic/subcomponents/devices/digital_display.dart';
import 'package:smmic/utils/datetime_formatting.dart';
import 'package:smmic/subcomponents/devices/battery_level.dart';
import 'package:smmic/subcomponents/devices/gauge.dart';

class SensorNodeCardExpanded extends StatefulWidget {
  const SensorNodeCardExpanded({
    super.key,
    required this.deviceID,
    required this.snapshot,
  });

  final SensorNodeSnapshot? snapshot;
  final String deviceID;


  @override
  State<SensorNodeCardExpanded> createState() => _SensorNodeCardExpandedState();
}

double getOpacity(ConnectivityResult connection) {
  double opacity = 1;
  switch (connection) {
    case ConnectivityResult.wifi:
      opacity = 1;
      break;
    case ConnectivityResult.mobile:
      opacity = 1;
      break;
    default:
      opacity = 0.25;
      break;
  }
  return opacity;
}


class _SensorNodeCardExpandedState extends State<SensorNodeCardExpanded> {
  final DateTimeFormatting _dateTimeFormatting = DateTimeFormatting();

  @override
  Widget build(BuildContext context) {

    SensorNodeSnapshot deviceSnapshot = context.watch<DevicesProvider>()
        .sensorNodeSnapshotMap[widget.deviceID]
        ?? SensorNodeSnapshot.placeHolder(deviceId: widget.deviceID);
    ConnectivityResult deviceConnectionStatus = context.watch<ConnectionProvider>().connectionStatus;
    int sensorConnectionState = context.watch<DevicesProvider>()
        .sensorStatesMap[widget.deviceID]!
        .connectionState.value1;

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
                    Icon(
                      CupertinoIcons.dot_radiowaves_left_right,
                      size: 29,
                      color: UiProvider().setConnectionColor(
                          deviceConnectionStatus,
                          sensorConnectionState
                      ),
                    ),
                    Text(
                        _dateTimeFormatting.formatTime(
                            widget.snapshot == null
                                ? DateTime.now()
                                : widget.snapshot!.timestamp
                        ),
                        style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 18.5
                        )
                    )
                  ],
                ),
              )
          ),
          Expanded(
            flex: 4,
            child: RadialGauge(
                valueType: ValueType.soilMoisture,
                value: deviceSnapshot.soilMoisture,
                limit: 100,
                scaleMultiplier: 1.5,
              opacity: getOpacity(deviceConnectionStatus),
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
                        valueType: ValueType.temperature,
                        value: deviceSnapshot.temperature,
                        limit: 100,
                        radiusMultiplier: 0.9,
                        opacity: getOpacity(deviceConnectionStatus),
                      ),
                    ),
                    SizedBox(
                      width: 160,
                      child: RadialGauge(
                        valueType: ValueType.humidity,
                        value: deviceSnapshot.humidity,
                        limit: 100,
                        radiusMultiplier: 0.9,
                        opacity: getOpacity(deviceConnectionStatus),
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
