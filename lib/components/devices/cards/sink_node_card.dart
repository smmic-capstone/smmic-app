import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smmic/models/device_data_models.dart';
import 'package:smmic/providers/devices_provider.dart';
import 'package:smmic/utils/device_utils.dart';

class SinkNodeCard extends StatefulWidget {
  const SinkNodeCard({
    super.key,
    required this.deviceInfo,
    this.bottomMargin,
    this.expanded = true,
    required this.currentDateTime
  });

  final SinkNode deviceInfo;
  final double? bottomMargin;
  final bool expanded;
  final DateTime currentDateTime;

  @override
  State<SinkNodeCard> createState() => _SinkNodeCardState();
}

class _SinkNodeCardState extends State<SinkNodeCard> {
  final DeviceUtils _deviceUtils = DeviceUtils();

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

  @override
  Widget build(BuildContext context) {

    SinkNodeState sinkState = context.watch<DevicesProvider>()
        .sinkNodeStateMap[widget.deviceInfo.deviceID]
        ?? SinkNodeState.initObj(widget.deviceInfo.deviceID);

    return Container(
      margin: EdgeInsets.only(left: 25, right: 25, bottom: widget.bottomMargin ?? 0),
      child: Stack(
        children: [
          _cardBackground(),
          Container(
            padding: const EdgeInsets.all(40),
            child: Column(
              children: [
                _skNameAndSignalIcon(sinkState.lastTransmission),
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
                SizedBox(height: widget.expanded ? 35 : 0),
                widget.expanded ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _bytesSentAndReceived(sinkState.bytesSent, sinkState.bytesReceived),
                    const Icon(
                        CupertinoIcons.arrow_right,
                        size: 35,
                        weight: 500,
                        color: Colors.white
                    )
                  ],
                ) : const SizedBox()
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _skNameAndSignalIcon(DateTime lastTransmission) {
    final double iconSize = widget.expanded ? 28 : 16;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 225,
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
        const SizedBox(height: 15),
        Column(
          children: [
            const SizedBox(height: 15),
            Builder(
              builder: (context) {
                Color iconColor = Colors.white.withOpacity(0.6);
                if (widget.currentDateTime.compareTo(
                    lastTransmission.add(const Duration(hours: 10))) == -1) {
                  iconColor = const Color.fromRGBO(23, 255, 50, 1);
                }
                return SvgPicture.asset(
                  'assets/icons/signal.svg',
                  width: iconSize,
                  height: iconSize,
                  colorFilter: ColorFilter.mode(
                      iconColor,
                      BlendMode.srcATop
                  ),
                );
              },
            )
          ],
        ),
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
    return Builder(
        builder: (context) {
          String displayText = _deviceUtils.relativeTimeDisplay(
              latestTimestamp,
              widget.currentDateTime
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

  Widget _bytesSentAndReceived(int bytesSent, int bytesReceived) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
              text: NumberFormat('#,##0').format(bytesSent + bytesReceived),
              style: const TextStyle(
                  fontSize: 30,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500
              ),
              children: const [
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
    double finalHeightExpanded = widget.deviceInfo.deviceName.length > 9
        ? 375
        : 315;
    double finalHeight = widget.deviceInfo.deviceName.length > 9
        ? 285
        : 228;
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(25)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaY: 10, sigmaX: 10),
        child: Container(
          height: widget.expanded ? finalHeightExpanded : finalHeight,
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
