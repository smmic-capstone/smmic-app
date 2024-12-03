import 'dart:async';
import 'dart:ui';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:smmic/models/device_data_models.dart';
import 'package:smmic/pages/devices_subpages/sensor_node_subpage.dart';
import 'package:smmic/providers/connections_provider.dart';
import 'package:smmic/subcomponents/devices/digital_display.dart';
import 'package:smmic/subcomponents/devices/gauge.dart';
import 'package:smmic/providers/devices_provider.dart';

class SensorNodeCard extends StatefulWidget {
  const SensorNodeCard({
    super.key,
    required this.deviceInfo,
    this.bottomMargin,
    required this.currentDateTime
  });

  final SensorNode deviceInfo;
  final double? bottomMargin;
  final DateTime currentDateTime;

  @override
  State<SensorNodeCard> createState() => _SensorNodeCardState();
}

class _SensorNodeCardState extends State<SensorNodeCard> {
  final TextStyle _primaryTextStyle = const TextStyle(
      fontSize: 32,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w500
  );

  final TextStyle _secondaryTextStyle = const TextStyle(
      fontFamily: 'Inter',
      fontSize: 18,
      fontWeight: FontWeight.w400
  );

  final TextStyle _tertiaryTextStyle = TextStyle(
      fontFamily: 'Inter',
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: Colors.white.withOpacity(0.5)
  );

  @override
  void initState(){
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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

  @override
  Widget build(BuildContext context) {

    // device connectivity status
    bool isConnected = context
        .watch<ConnectionProvider>().deviceIsConnected;

    // sensor data
    SensorNodeSnapshot seSnapshotData = context.watch<DevicesProvider>()
        .sensorNodeSnapshotMap[widget.deviceInfo.deviceID]
        ?? SensorNodeSnapshot.placeHolder(
            deviceId: widget.deviceInfo.deviceID,
            timestamp: DateTime.fromMillisecondsSinceEpoch(989452800000)
        );

    // sensor states
    SMSensorState sensorState = context.watch<DevicesProvider>()
        .sensorStatesMap[widget.deviceInfo.deviceID]
        ?? SMSensorState.initObj(widget.deviceInfo.deviceID);

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => SensorNodePage(
                deviceID: widget.deviceInfo.deviceID,
                deviceName: widget.deviceInfo.deviceName,
                deviceInfo: widget.deviceInfo
            )
        ));
      },
      child: Container(
        margin: EdgeInsets.only(
            left: 25,
            right: 25,
            bottom: widget.bottomMargin ?? 0
        ),
        child: Stack(
          children: [
            _cardBackground(),
            Container(
              padding: const EdgeInsets.all(40),
              child: Stack(
                children: [
                  SizedBox(
                    width: 230,
                    child: _nameAndReadings(
                        seSnapshotData
                    ),
                  ),
                  SizedBox(
                    height: widget.deviceInfo.deviceName.length > 9 ? 201 : 144,
                    child: Stack(
                      children: [
                        _topRightIcons(
                            isConnected,
                            sensorState.connectionState
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: _gauge(seSnapshotData),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _nameAndReadings(SensorNodeSnapshot snapshotData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 250,
          child: Text(
            softWrap: true,
            widget.deviceInfo.deviceName,
            style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Inter',
                fontSize: 40
            ),
          ),
        ),
        const SizedBox(height: 35),
        Row(
          children: [
            SensorDigitalDisplay(
              value: snapshotData.temperature,
              valueType: ValueType.temperature,
              opacityOverride: 1,
              valueTextStyle: _primaryTextStyle,
              secondaryTextStyle: _secondaryTextStyle,
              tertiaryTextStyle: _tertiaryTextStyle,
            ),
            const SizedBox(width: 15),
            SensorDigitalDisplay(
              value: snapshotData.humidity,
              valueType: ValueType.humidity,
              opacityOverride: 1,
              valueTextStyle: _primaryTextStyle,
              secondaryTextStyle: _secondaryTextStyle,
              tertiaryTextStyle: _tertiaryTextStyle,
            )
          ],
        ),
      ],
    );
  }

  Widget _topRightIcons(
      bool isConnected,
      (int, DateTime, DateTime) seConnectionState) {

    Widget signalIcon() {
      Color finalColor = const Color.fromRGBO(23, 255, 50, 1);

      if (!isConnected) {
        finalColor = Colors.white.withOpacity(0.35);
      } else if (seConnectionState.$1 != SMSensorAlertCodes.connectedState.code) {
        finalColor = Colors.white.withOpacity(0.35);
      } else if (seConnectionState.$2.isBefore(widget.currentDateTime)) {
        finalColor = const Color.fromRGBO(23, 255, 50, 0.25);
      }

      return SvgPicture.asset(
        'assets/icons/signal.svg',
        width: 16,
        height: 16,
        colorFilter: ColorFilter.mode(
            finalColor,
            BlendMode.srcIn
        ),
      );
    }

    return Positioned(
      top: 10,
      right: 0,
      child: Row(
        children: [
          signalIcon()
        ],
      ),
    );
  }

  Widget _gauge(SensorNodeSnapshot snapshotData) {
    return SizedBox(
      width: 115,
      height: 115,
      child: RadialGauge(
        valueType: ValueType.soilMoisture,
        value: snapshotData.soilMoisture,
        limit: 100,
        opacity: 1,
        valueTextStyle: _primaryTextStyle,
        symbolTextStyle: _secondaryTextStyle,
        labelTextStyle: _tertiaryTextStyle,
      ),
    );
  }

  Widget _cardBackground() {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(25)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaY: 10, sigmaX: 10),
        child: Container(
          height: widget.deviceInfo.deviceName.length > 9 ? 282 : 226,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.65),
            borderRadius: const BorderRadius.all(
                Radius.circular(25)
            ),
          ),
        ),
      ),
    );
  }
}
