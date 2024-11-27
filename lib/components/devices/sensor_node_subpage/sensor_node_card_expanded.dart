import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:smmic/models/device_data_models.dart';
import 'package:smmic/providers/connections_provider.dart';
import 'package:smmic/providers/devices_provider.dart';
import 'package:smmic/providers/theme_provider.dart';
import 'package:smmic/subcomponents/devices/digital_display.dart';
import 'package:smmic/utils/datetime_formatting.dart';
import 'package:smmic/subcomponents/devices/gauge.dart';

class SensorNodeCardExpanded extends StatefulWidget {
  const SensorNodeCardExpanded({
    super.key,
    required this.deviceID,
  });

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
  final TextStyle _primaryTextStyle = const TextStyle(
      fontSize: 43,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w500
  );

  final TextStyle _secondaryTextStyle = const TextStyle(
      fontFamily: 'Inter',
      fontSize: 21,
      fontWeight: FontWeight.w400
  );

  final TextStyle _tertiaryTextStyle = TextStyle(
      fontFamily: 'Inter',
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Colors.white.withOpacity(0.5)
  );

  @override
  Widget build(BuildContext context) {
    // device reading data
    final SensorNodeSnapshot snapshot = context.watch<DevicesProvider>()
        .sensorNodeSnapshotMap[widget.deviceID]
        ?? SensorNodeSnapshot.placeHolder(deviceId: widget.deviceID);
    // connectivity status
    final ConnectivityResult connectionStatus = context.watch<ConnectionProvider>().connectionStatus;
    return _background(
      child: Column(
        children: [
          _topIcons(),
          const SizedBox(height: 25),
          SizedBox(
            height: 170,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _radialGauge(
                    snapshot.soilMoisture,
                    connectionStatus
                ),
                _digitalDisplays(
                    snapshot.temperature,
                    snapshot.humidity
                )
              ],
            ),
          ),
          const SizedBox(height: 35),
          _irrigation()
        ],
      )
    );
  }

  Widget _background({required Widget child}) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(25)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaY: 10, sigmaX: 10),
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.all(Radius.circular(25))
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _topIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SvgPicture.asset(
          'assets/icons/signal.svg',
          width: 28,
          height: 28,
          colorFilter: const ColorFilter.mode(
              Color.fromRGBO(23, 255, 50, 1),
              BlendMode.srcATop
          ),
        ),
        Icon(
          CupertinoIcons.refresh,
          size: 30,
          color: Colors.white.withOpacity(0.5),
        )
      ],
    );
  }

  Widget _radialGauge(double soilMoisture, ConnectivityResult deviceConnStatus) {
    return Container(
      width: 165,
      height: 170,
      child: RadialGauge(
        valueType: ValueType.soilMoisture,
        value: soilMoisture,
        limit: 100,
        scaleMultiplier: 1.5,
        opacity: getOpacity(deviceConnStatus),
        valueTextStyle: _primaryTextStyle,
        labelTextStyle: _tertiaryTextStyle,
        symbolTextStyle: _secondaryTextStyle,
      ),
    );
  }
  
  Widget _digitalDisplays(double temperature, double humidity) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SensorDigitalDisplay(
          expanded: true,
          value: humidity,
          valueType: ValueType.humidity,
          opacityOverride: 1,
          valueTextStyle: _primaryTextStyle,
          secondaryTextStyle: _secondaryTextStyle,
          tertiaryTextStyle: _tertiaryTextStyle,
        ),
        const SizedBox(height: 25),
        SensorDigitalDisplay(
          expanded: true,
          value: temperature,
          valueType: ValueType.temperature,
          opacityOverride: 1,
          valueTextStyle: _primaryTextStyle,
          secondaryTextStyle: _secondaryTextStyle,
          tertiaryTextStyle: _tertiaryTextStyle,
        ),
      ],
    );
  }

  Widget _irrigation() {
    return Row(
      children: [
        Stack(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                //color: Color.fromRGBO(23, 255, 50, 1),
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
            ),
            Positioned(
              top: 12.5,
              left: 0,
              right: 0,
              child: SvgPicture.asset(
                colorFilter: ColorFilter.mode(
                  Colors.white.withOpacity(1),
                  BlendMode.srcIn
                ),
                clipBehavior: Clip.antiAlias,
                'assets/icons/droplet.svg',
                height: 25,
                width: 25,
              ),
            )
          ],
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '<1 minute ago',
              style: TextStyle(
                fontFamily: 'Inter',
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500
              ),
            ),
            Text(
              'Last Irrigation',
              style: TextStyle(
                fontFamily: 'Inter',
                color: Colors.white.withOpacity(0.5),
                fontSize: 13
              ),
            )
          ],
        )
      ],
    );
  }

}
