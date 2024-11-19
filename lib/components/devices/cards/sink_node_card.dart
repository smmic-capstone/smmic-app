import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:smmic/models/device_data_models.dart';
import 'package:smmic/providers/devices_provider.dart';
import 'package:smmic/providers/theme_provider.dart';
import 'package:smmic/subcomponents/devices/battery_level.dart';
import 'package:smmic/subcomponents/devices/device_dialog.dart';
import 'package:smmic/subcomponents/devices/device_name.dart';

class SinkNodeCard extends StatefulWidget {
  const SinkNodeCard({
    super.key,
    required this.deviceInfo
  });

  final SinkNode deviceInfo;

  @override
  State<SinkNodeCard> createState() => _SinkNodeCardState();
}

class _SinkNodeCardState extends State<SinkNodeCard> {
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
      color: Colors.white.withOpacity(0.5)
  );

  Stream<DateTime> _timeTickerSeconds() async* {
    while (true) {
      yield DateTime.now();
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    SinkNodeState sinkState = context.watch<DevicesProvider>().sinkNodeStateMap[widget.deviceInfo.deviceID]!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      child: Stack(
        children: [
          _cardBackground(),
          Container(
            padding: const EdgeInsets.all(40),
            child: Column(
              children: [
                _skNameAndSignalIcon(),
                const SizedBox(height: 35),
                Row(
                  children: [
                    _sensorsConnected(
                      connected: sinkState.sensorsConnectionStateMap.keys
                          .where((sensor) => sinkState.sensorsConnectionStateMap[sensor] == ConnectionState.active)
                          .toList().length,
                      total: widget.deviceInfo.registeredSensorNodes.length
                    ),
                    const SizedBox(width: 30),
                    _lastTransmission(
                        latestTimestamp: sinkState.lastTransmission
                    )
                  ],
                ),
                const SizedBox(height: 35),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _bytesDisplayAndBackIcon(sinkState.bytesSent),
                    // SvgPicture.asset(
                    //   'assets/icons/signal.svg',
                    //   width: 28,
                    //   height: 28,
                    //   colorFilter: const ColorFilter.mode(
                    //       Colors.white,
                    //       BlendMode.srcATop
                    //   ),
                    // ) // TODO: ilisdan og back button
                    const Icon(
                        CupertinoIcons.arrow_right,
                        size: 35,
                        weight: 500,
                        color: Colors.white
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _skNameAndSignalIcon() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.deviceInfo.deviceName,
          style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Inter',
              fontSize: 40
          ),
        ),
        SvgPicture.asset(
          'assets/icons/signal.svg',
          width: 28,
          height: 28,
          colorFilter: const ColorFilter.mode(
            Colors.white,
            BlendMode.srcATop
          ),
        )
      ],
    );
  }

  Widget _sensorsConnected({required int connected, required int total}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        RichText(
          text: TextSpan(
              children: [
                TextSpan(
                    text: connected.toString(),
                    style: _primaryTextStyle
                ),
                TextSpan(
                    text: ' / ${total.toString()}',
                    style: _secondaryTextStyle
                ),
              ]
          ),
        ),
        Text(
          'Sensors Active',
          style: _tertiaryTextStyle,
        )
      ],
    );
  }

  Widget _lastTransmission({required DateTime latestTimestamp}) {
    // stream builder to get data from time ticker function
    return StreamBuilder<DateTime>(
        stream: _timeTickerSeconds(),
        builder: (context, snapshot) {
          String displayText = _dynamicTimeDisplay(
              latestTimestamp,
              snapshot.data ?? DateTime.now()
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              RichText(
                text: TextSpan(
                    children: [
                      TextSpan(
                          text: displayText.split(" ").first,
                          style: _primaryTextStyle
                      ),
                      TextSpan(
                          text: " ${displayText.split(" ")[1]} ${displayText.split(" ")[2]}",
                          style: _secondaryTextStyle
                      )
                    ]
                ),
              ),
              Text(
                  'Last Transmission',
                  style: _tertiaryTextStyle
              )
            ],
          );
        }
    );
  }

  String _dynamicTimeDisplay(DateTime latestTime, DateTime currentTime) {
    Duration diff = currentTime.difference(latestTime);

    String finalString = '';

    if (diff < const Duration(minutes: 1)) {
      finalString = '<1 minute ago';
    } else if (diff >= const Duration(minutes: 1) && diff < const Duration(minutes: 2)) {
      finalString = '${diff.inMinutes} minute ago';
    } else if (diff >= const Duration(minutes: 2) && diff < const Duration(hours: 1)) {
      finalString = '${diff.inMinutes} minutes ago';
    } else if (diff >= const Duration(hours: 1) && diff < const Duration(hours: 2)) {
      finalString = '${diff.inHours} hour ago';
    } else if (diff >= const Duration(hours: 2) && diff < const Duration(days: 1)) {
      finalString = '${diff.inHours} hours ago';
    } else if (diff >= const Duration(days: 1) && diff < const Duration(days: 2)) {
      finalString = '${diff.inDays} day ago';
    } else if (diff >= const Duration(days: 2)) {
      finalString = '${diff.inDays} days ago';
    }

    return finalString;
  }

  Widget _bytesDisplayAndBackIcon(double bytesSent) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
              text: bytesSent.toInt().toString(),
              style: TextStyle(
                  fontSize: 30,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500
              ),
              children: [
                TextSpan(
                    text: ' bytes',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.w400
                    )
                )
              ]
          ),
        ),
        Text(
          'Sent and Received',
          style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.5)
          ),
        )
      ],
    );
  }

  Widget _cardBackground() {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(25)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaY: 10, sigmaX: 10),
        child: Container(
          height: 315,
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
