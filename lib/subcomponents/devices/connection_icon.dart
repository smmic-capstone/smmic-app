import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smmic/models/device_data_models.dart';
import 'package:smmic/providers/connections_provider.dart';
import 'package:smmic/providers/devices_provider.dart';

class ConnectionStateIcon extends StatefulWidget {
  final String deviceID;

  const ConnectionStateIcon({
    super.key,
    required this.deviceID
  });

  @override
  State<ConnectionStateIcon> createState() => _ConnectionStateIconState();
}

class _ConnectionStateIconState extends State<ConnectionStateIcon> {
  late Timer _timer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // _expireTimer(
    //     context.watch<DevicesProvider>().sensorStatesMap[widget.deviceID]!.lastUpdate,
    //     context
    // );
    return Icon(
        CupertinoIcons.dot_radiowaves_left_right,
        color: _setConnectionColor(
            context.watch<ConnectionProvider>().connectionStatus,
            context.watch<DevicesProvider>().sensorStatesMap[widget.deviceID]!.connectionState.value1
        ),
        size: 24
    );
  }

  Color _setConnectionColor(ConnectivityResult connectionStatus, int sensorConnectionState) {
    Color finalColor = const Color.fromRGBO(76, 166, 42, 0.9);
    if (connectionStatus == ConnectivityResult.none
        || sensorConnectionState == SMSensorAlertCodes.disconnectedState.code) {
      finalColor = Colors.black.withOpacity(0.2);
    }
    return finalColor;
  }
}