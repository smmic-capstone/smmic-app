import 'dart:ui';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';
import 'package:smmic/constants/api.dart';
import 'package:smmic/models/device_data_models.dart';
import 'package:smmic/providers/auth_provider.dart';
import 'package:smmic/providers/connections_provider.dart';
import 'package:smmic/providers/devices_provider.dart';
import 'package:smmic/providers/theme_provider.dart';
import 'package:smmic/services/devices_services.dart';
import 'package:smmic/subcomponents/devices/device_dialog.dart';
import 'package:smmic/subcomponents/devices/digital_display.dart';
import 'package:smmic/utils/api.dart';
import 'package:smmic/utils/datetime_formatting.dart';
import 'package:smmic/subcomponents/devices/gauge.dart';

class SensorNodeCardExpanded extends StatefulWidget {
  const SensorNodeCardExpanded({super.key, required this.deviceID, required this.currentDateTime});

  final String deviceID;
  final DateTime currentDateTime;

  @override
  State<SensorNodeCardExpanded> createState() => _SensorNodeCardExpandedState();
}

class _SensorNodeCardExpandedState extends State<SensorNodeCardExpanded> {
  final ApiRequest _apiRequest = ApiRequest();
  final ApiRoutes _apiRoutes = ApiRoutes();
  final DevicesServices _devicesServices = DevicesServices();

  final Duration awaitIrrResponseDuration = const Duration(seconds: 30);
  DateTime lastIrrCommandSent = DateTime.fromMillisecondsSinceEpoch(0);

  TextEditingController editController = TextEditingController();
  int _intervalValue = 5;
  Color saveButtonColor = Colors.green.withOpacity(0.25);

  @override
  void initState() {
    super.initState();
  }

  final TextStyle _primaryTextStyle = const TextStyle(fontSize: 43, fontFamily: 'Inter', fontWeight: FontWeight.w500);

  final TextStyle _secondaryTextStyle = const TextStyle(fontFamily: 'Inter', fontSize: 21, fontWeight: FontWeight.w400);

  final TextStyle _tertiaryTextStyle =
      TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white.withOpacity(0.5));

  Future<bool> _sendIrrigationCommand(String deviceId, int command) async {
    bool result = false;

    setState(() {
      lastIrrCommandSent = DateTime.now();
    });

    await _apiRequest.sendIrrigationCommand(deviceId: deviceId, command: command);

    return result;
  }

  @override
  void dispose() {
    editController.dispose();
    super.dispose();
  }

  Future<void> save(BuildContext context, String field, SensorNode deviceInfo) async {

    if (field == 'Device Name') {
      await _devicesServices.updateSNDeviceName(
        token: context.read<AuthProvider>().accessData!.token,
        deviceID: widget.deviceID,
        sensorName: {'name': editController.text},
        sinkNodeID: deviceInfo.registeredSinkNode,
      );
      if (context.mounted) {
        context.read<DevicesProvider>().sensorNameChange({
          SensorNodeKeys.deviceID.key: widget.deviceID,
          'name': editController.text,
          'longitude': deviceInfo.longitude ?? '',
          'latitude': deviceInfo.latitude ?? '',
          SensorNodeKeys.sinkNode.key: deviceInfo.registeredSinkNode,
          SensorNodeKeys.interval.key: deviceInfo.interval
        });
      }
    } else if (field == 'Longitude') {
      await _devicesServices.updateSNDeviceName(
          token: context.read<AuthProvider>().accessData!.token,
          deviceID: widget.deviceID,
          sensorName: {'longitude': editController.text},
          sinkNodeID: deviceInfo.registeredSinkNode);
      if (context.mounted) {
        context.read<DevicesProvider>().sensorNameChange({
          SensorNodeKeys.deviceID.key: widget.deviceID,
          'name': deviceInfo.deviceName,
          'longitude': editController.text ?? '',
          'latitude': deviceInfo.latitude ?? '',
          SensorNodeKeys.sinkNode.key: deviceInfo.registeredSinkNode,
          SensorNodeKeys.interval.key: deviceInfo.interval
        });
      }
    } else if (field == 'Latitude') {
      await _devicesServices.updateSNDeviceName(
          token: context.read<AuthProvider>().accessData!.token,
          deviceID: widget.deviceID,
          sensorName: {'latitude': editController.text},
          sinkNodeID: deviceInfo.registeredSinkNode);
      if (context.mounted) {
        context.read<DevicesProvider>().sensorNameChange({
          SensorNodeKeys.deviceID.key: widget.deviceID,
          'name': deviceInfo.deviceName,
          'longitude': deviceInfo.longitude ?? '',
          'latitude': editController.text ?? '',
          SensorNodeKeys.sinkNode.key: deviceInfo.registeredSinkNode,
          SensorNodeKeys.interval.key: deviceInfo.interval
        });
      }
    } else if (field == 'Interval') {
      await _apiRequest.sendIntervalCommand(
          newInterval: Duration(minutes: int.parse(editController.text)), deviceId: deviceInfo.deviceID);
      await _devicesServices.updateSNDeviceName(
          token: context.read<AuthProvider>().accessData!.token,
          deviceID: widget.deviceID,
          sensorName: {'interval': (int.parse(editController.text) * 60)},
          sinkNodeID: deviceInfo.registeredSinkNode);
      if (context.mounted) {
        context.read<DevicesProvider>().sensorNameChange({
          SensorNodeKeys.deviceID.key: widget.deviceID,
          'name': deviceInfo.deviceName,
          'longitude': deviceInfo.longitude ?? '',
          'latitude': deviceInfo.latitude ?? '',
          SensorNodeKeys.sinkNode.key: deviceInfo.registeredSinkNode,
          SensorNodeKeys.interval.key: int.parse(editController.text) * 60
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // device reading data
    final SensorNodeSnapshot snapshot =
        context.watch<DevicesProvider>().sensorNodeSnapshotMap[widget.deviceID] ?? SensorNodeSnapshot.placeHolder(deviceId: widget.deviceID);

    // device connectivity status
    final bool isConnected = context.watch<ConnectionProvider>().deviceIsConnected;

    // sensor state
    final SMSensorState sensorState = context.watch<DevicesProvider>().sensorStatesMap[widget.deviceID] ?? SMSensorState.initObj(widget.deviceID);

    return _background(
        child: Column(
      children: [
        _topIcons(isConnected, snapshot.timestamp),
        const SizedBox(height: 25),
        SizedBox(
          height: 170,
          child: Stack(
            children: [_radialGauge(snapshot.soilMoisture), _digitalDisplays(snapshot.temperature, snapshot.humidity)],
          ),
        ),
        const SizedBox(height: 35),
        _irrigation(sensorState)
      ],
    ));
  }

  Widget _background({required Widget child}) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(25)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaY: 10, sigmaX: 10),
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.65), borderRadius: const BorderRadius.all(Radius.circular(25))),
          child: child,
        ),
      ),
    );
  }

  void showEditDialog(BuildContext context, String value, String field, SensorNode deviceInfo) {
    String initialValue = value;

    setState(() {
      editController.text = value;
    });

    Widget fieldInput() {
      if (field == 'Device Name') {
        return TextField(
          decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.5),
                    width: 0.5,
                  ))),
          controller: editController,
          style: TextStyle(color: Colors.white, fontFamily: 'Inter', fontSize: 20),
        );
      } else if (field == 'Interval') {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // GestureDetector(
            //   onTap: () {
            //     setState(() {
            //       _intervalValue = _intervalValue - 1;
            //     });
            //   },
            //   child: Text(
            //       '-',
            //       style: TextStyle(
            //           color: Colors.white,
            //           fontFamily: 'Inter',
            //           fontSize: 40
            //       )
            //   ),
            // ),
            // SizedBox(width: 15),
            ListenableBuilder(
                listenable: (editController),
                builder: (context, child) {
                  return NumberPicker(
                    itemWidth: 125,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.1)),
                    selectedTextStyle: const TextStyle(color: Colors.white, fontFamily: 'Inter', fontSize: 20),
                    textStyle: TextStyle(color: Colors.white.withOpacity(0.25), fontFamily: 'Inter', fontSize: 20),
                    minValue: 5,
                    maxValue: 25,
                    value: int.parse(editController.text),
                    textMapper: (value) {
                      return '$value Minutes';
                    },
                    onChanged: (value) {
                      setState(() {
                        editController.text = value.toString();
                      });
                    },
                    infiniteLoop: true,
                  );
                }),
            // SizedBox(width: 15),
            // GestureDetector(
            //   onTap: () {
            //     setState(() {
            //       _intervalValue = _intervalValue + 1;
            //     });
            //   },
            //   child: Text(
            //       '+',
            //       style: TextStyle(
            //           color: Colors.white,
            //           fontFamily: 'Inter',
            //           fontSize: 30
            //       )
            //   ),
            // ),
          ],
        );
      } else {
        return Container();
      }
    }

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return Flex(
            mainAxisAlignment: MainAxisAlignment.center,
            direction: Axis.vertical,
            children: [
              Container(
                  padding: EdgeInsets.only(bottom: 25, top: 25),
                  margin: EdgeInsets.symmetric(horizontal: 30),
                  decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(25)), color: Colors.black),
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(bottom: 15),
                        child: Text(
                          'Set New $field',
                          style: TextStyle(color: Colors.white, fontFamily: 'Inter', fontSize: 20),
                        ),
                      ),
                      Card(
                        margin: EdgeInsets.symmetric(horizontal: 25),
                        color: Colors.transparent,
                        shadowColor: Colors.transparent,
                        surfaceTintColor: Colors.transparent,
                        child: fieldInput(),
                      ),
                      const SizedBox(height: 15),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.white)),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                alignment: Alignment.center,
                                width: 80,
                                height: 30,
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.black, fontSize: 20, fontFamily: 'Inter'),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            ListenableBuilder(
                                listenable: editController,
                                builder: (context, child) {
                                  return TextButton(
                                    style: ButtonStyle(
                                        backgroundColor: WidgetStatePropertyAll(
                                            editController.text != initialValue ? Colors.green : Colors.green.withOpacity(0.25))),
                                    onPressed: editController.text == initialValue
                                        ? null
                                        : () async {
                                            showDialog(
                                              barrierDismissible: false,
                                                context: context,
                                                builder: (context) {
                                                  return FutureBuilder(
                                                      future: save(context, field, deviceInfo),
                                                      builder: (context, snapshot) {
                                                        if (snapshot.connectionState == ConnectionState.done) {
                                                          Navigator.pop(context);
                                                          Navigator.pop(context);
                                                        }
                                                        return const Center(
                                                          child: CircularProgressIndicator(
                                                            color: Colors.white,
                                                          ),
                                                        );
                                                      }
                                                  );
                                                }
                                            );
                                          },
                                    child: Container(
                                      alignment: Alignment.center,
                                      width: 60,
                                      height: 30,
                                      child: const Text(
                                        'Save',
                                        style: TextStyle(color: Colors.white, fontSize: 20, fontFamily: 'Inter'),
                                      ),
                                    ),
                                  );
                                }),
                          ],
                        ),
                      )
                    ],
                  )),
            ],
          );
        });
  }

  Widget _topIcons(bool isConnected, DateTime lastTimestamp) {
    Widget signalIcon() {
      Color finalColor = const Color.fromRGBO(23, 255, 50, 1);

      if (widget.currentDateTime.difference(lastTimestamp) > const Duration(minutes: 5)) {
        finalColor = Colors.white.withOpacity(0.35);
        //finalColor = const Color.fromRGBO(23, 255, 50, 0.25);
      }

      // if (widget.currentDateTime.difference(lastTimestamp) > const Duration(minutes: 5)) {
      //   if (seConnectionState.$1 == SMSensorAlertCodes.connectedState.code) {
      //     finalColor = const Color.fromRGBO(23, 255, 50, 0.25);
      //   } else if (seConnectionState.$1 == SMSensorAlertCodes.disconnectedState.code) {
      //     finalColor = const Color.fromRGBO(255, 23, 25, 0.25);
      //   } else if (seConnectionState.$1 == SMSensorAlertCodes.unverifiedState.code) {
      //     finalColor = Colors.white.withOpacity(0.35);
      //   }
      // }

      if (!isConnected) {
        finalColor = Colors.white.withOpacity(0.35);
      }

      return SvgPicture.asset(
        'assets/icons/signal.svg',
        width: 28,
        height: 28,
        colorFilter: ColorFilter.mode(finalColor, BlendMode.srcIn),
      );
    }

    Widget settingsIcon() {
      sensorConfigDialog() {
        Widget topIcons = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              child: SvgPicture.asset(
                'assets/icons/settings.svg',
                width: 26,
                height: 26,
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
              onTap: () {},
            ),
            const SizedBox(width: 15),
            const Text(
              'Device Settings',
              style: TextStyle(color: Colors.white, fontSize: 25, fontFamily: 'Inter'),
            ),
            // GestureDetector(
            //   onTap: () {
            //     Navigator.pop(context);
            //   },
            //   child: Icon(
            //     CupertinoIcons.xmark,
            //     size: 27,
            //     color: Colors.white,
            //   ),
            // ),
          ],
        );

        Widget deviceName(SensorNode deviceInfo) {
          return SizedBox(
            child: RichText(
              text: TextSpan(
                  text: deviceInfo.deviceName ?? 'Unknown',
                  style: const TextStyle(color: Colors.white, fontSize: 25, fontFamily: 'Inter'),
                  children: [TextSpan(text: '\nDevice Name', style: _tertiaryTextStyle)]),
            ),
          );
        }

        Widget readingInterval(SensorNode deviceInfo) {
          return Container(
            constraints: const BoxConstraints(maxWidth: 150),
            child: RichText(
              text: TextSpan(
                  text: '${(deviceInfo!.interval ~/ 60).toString()} Minutes',
                  style: const TextStyle(color: Colors.white, fontSize: 25, fontFamily: 'Inter'),
                  children: [TextSpan(text: '\nReading Interval', style: _tertiaryTextStyle)]),
            ),
          );
        }

        List<Widget> coordinates(SensorNode deviceInfo) {
          return [
            Divider(
              height: 0.5,
              color: Colors.white.withOpacity(0.25),
            ),
            GestureDetector(
              onTap: () {
                showEditDialog(context, deviceInfo.longitude ?? '', 'Longitude', deviceInfo);
              },
              child: Container(
                color: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                child: Row(
                  children: [
                    Container(
                      constraints: const BoxConstraints(maxWidth: 150),
                      child: RichText(
                        text: TextSpan(
                            text: deviceInfo.longitude ?? 'Longitude',
                            style: TextStyle(
                                color: deviceInfo.latitude != null ? Colors.white : Colors.white.withOpacity(0.5), fontSize: 25, fontFamily: 'Inter'),
                            children: [TextSpan(text: deviceInfo.latitude != null ? '\nLongitude' : '\nNot Set', style: _tertiaryTextStyle)]),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Divider(
              height: 0.5,
              color: Colors.white.withOpacity(0.25),
            ),
            GestureDetector(
              onTap: () {
                showEditDialog(context, deviceInfo.latitude ?? '', 'latitude', deviceInfo);
              },
              child: Container(
                color: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                child: Row(
                  children: [
                    Container(
                      constraints: const BoxConstraints(maxWidth: 150),
                      child: RichText(
                        text: TextSpan(
                            text: deviceInfo.latitude ?? 'Latitude',
                            style: TextStyle(
                                color: deviceInfo.latitude != null ? Colors.white : Colors.white.withOpacity(0.5), fontSize: 25, fontFamily: 'Inter'),
                            children: [TextSpan(text: deviceInfo.latitude != null ? '\nLatitude' : '\nNot Set', style: _tertiaryTextStyle)]),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Divider(
              height: 0.5,
              color: Colors.white.withOpacity(0.25),
            ),
          ];
        }

        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              SensorNode deviceInfo = context.watch<DevicesProvider>().sensorNodeMap[widget.deviceID]!;

              return BackdropFilter(
                filter: ImageFilter.blur(sigmaY: 10, sigmaX: 10),
                child: Flex(
                  direction: Axis.vertical,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(15)),
                        color: Colors.black.withOpacity(0.75),
                      ),
                      padding: const EdgeInsets.only(
                          //horizontal: 40,
                          top: 40,
                          bottom: 13),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 25,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 30),
                            child: topIcons,
                          ),
                          // Divider(
                          //     height: 0.5,
                          //   color: Colors.white.withOpacity(0.25),
                          // ),
                          Divider(
                            height: 0.5,
                            color: Colors.white.withOpacity(0.25),
                          ),
                          GestureDetector(
                            onTap: () {
                              showEditDialog(context, deviceInfo?.deviceName ?? 'Sensor Node', 'Device Name', deviceInfo!);
                            },
                            child: Container(
                              color: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                              child: Row(
                                children: [deviceName(deviceInfo)],
                              ),
                            ),
                          ),
                          Divider(
                            height: 0.5,
                            color: Colors.white.withOpacity(0.25),
                          ),
                          GestureDetector(
                            onTap: () {
                              showEditDialog(context, (deviceInfo!.interval ~/ 60).toString(), 'Interval', deviceInfo!);
                            },
                            child: Container(
                              color: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                              child: Row(
                                children: [readingInterval(deviceInfo)],
                              ),
                            ),
                          ),
                          ...coordinates(deviceInfo),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const SizedBox(
                                  width: 110,
                                  height: 40,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        CupertinoIcons.arrow_left,
                                        color: Colors.white,
                                        size: 27,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        'Back',
                                        style: TextStyle(color: Colors.white, fontSize: 23, fontFamily: 'Inter'),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 25),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              );
            });
      }

      return GestureDetector(
        onTap: () {
          sensorConfigDialog();
        },
        child: SvgPicture.asset(
          'assets/icons/settings.svg',
          width: 28,
          height: 28,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [signalIcon(), settingsIcon()],
    );
  }

  Widget _radialGauge(double soilMoisture) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 155,
          height: 165,
          child: RadialGauge(
            valueType: ValueType.soilMoisture,
            value: soilMoisture,
            limit: 100,
            scaleMultiplier: 1.5,
            opacity: 1,
            valueTextStyle: _primaryTextStyle,
            labelTextStyle: _tertiaryTextStyle,
            symbolTextStyle: _secondaryTextStyle,
          ),
        )
      ],
    );
  }

  Widget _digitalDisplays(double temperature, double humidity) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
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

  Widget _irrigation(SMSensorState sensorState) {
    Duration diff = widget.currentDateTime.difference(lastIrrCommandSent);

    if (sensorState.irrigationState.$2.isAfter(lastIrrCommandSent)) {
      setState(() {
        lastIrrCommandSent = DateTime.fromMillisecondsSinceEpoch(0);
      });
    }

    // subscription state of the commands channel
    bool irrChannelSubState = context.watch<ConnectionProvider>().channelsSubStateMap[_apiRoutes.userCommands] ?? false;

    // other variables
    bool isDarkMode = context.watch<UiProvider>().isDark;
    bool isConnected = context.watch<ConnectionProvider>().deviceIsConnected;

    bool isIrrigating() {
      return sensorState.irrigationState.$1 == SMSensorAlertCodes.irrOn.code;
    }

    Color buttonBg() {
      Color finalColor = Colors.white;

      if (!isConnected) {
        return Colors.white;
      }

      if (irrChannelSubState) {
        finalColor = const Color.fromRGBO(98, 245, 255, 1);
      } else {
        finalColor = Colors.white;
      }
      return finalColor;
    }

    Color buttonIconColor() {
      Color finalColor = Colors.white;

      if (!isConnected) {
        return Colors.white.withOpacity(0.5);
      }

      if (irrChannelSubState) {
        finalColor = const Color.fromRGBO(98, 245, 255, 1);
      } else {
        finalColor = Colors.white.withOpacity(0.5);
      }
      return finalColor;
    }

    Widget dropletIcon = Positioned(
      top: 12.3,
      left: 0,
      right: 0,
      child: SvgPicture.asset(
        colorFilter: ColorFilter.mode(buttonIconColor(), BlendMode.srcIn),
        clipBehavior: Clip.antiAlias,
        'assets/icons/droplet.svg',
        height: 26,
        width: 26,
      ),
    );

    Widget awaitingCommandSent = Positioned(
      top: 14,
      left: 15,
      child: SizedBox(
        width: 21,
        height: 21,
        child: CircularProgressIndicator(
          strokeWidth: 2.25,
          color: Colors.white.withOpacity(0.7),
        ),
      ),
    );

    Widget button = Stack(
      children: [
        AnimatedOpacity(
          opacity: isIrrigating()
              ? 0.6
              : !isConnected
                  ? 0.75
                  : 0.15,
          duration: const Duration(milliseconds: 250),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              //color: Color.fromRGBO(23, 255, 50, 1),
              color: buttonBg(),
              borderRadius: const BorderRadius.all(Radius.circular(13)),
            ),
          ),
        ),
        diff < awaitIrrResponseDuration ? awaitingCommandSent : dropletIcon
      ],
    );

    String finalText() {
      String text = '';

      if (!irrChannelSubState || !isConnected) {
        return 'Unavailable';
      }

      if (sensorState.irrigationState.$1 == SMSensorAlertCodes.irrOn.code) {
        return 'Irrigating';
      }

      if (diff < awaitIrrResponseDuration) {
        text = 'Waiting';
      } else if (diff > awaitIrrResponseDuration) {
        text = 'Irrigate';
      }

      return text;
    }

    String finalSubText() {
      String text = 'Last Irrigation';

      if (!isConnected) {
        return 'Your device is not connected!';
      } else if (!irrChannelSubState) {
        return 'Service is unavailable';
      }

      if (sensorState.irrigationState.$1 == SMSensorAlertCodes.irrOn.code) {
        return 'Irrigation in progress...';
      }

      if (diff < awaitIrrResponseDuration) {
        text = 'Sending command...';
      } else if (diff > awaitIrrResponseDuration) {
        text = 'Send irrigation command...';
      }

      return text;
    }

    Widget text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          finalText(),
          style: const TextStyle(fontFamily: 'Inter', color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
        ),
        Text(
          finalSubText(),
          style: TextStyle(fontFamily: 'Inter', color: Colors.white.withOpacity(0.5), fontSize: 13),
        )
      ],
    );

    return Row(
      children: [
        InkWell(
          onTap: () async {
            if (irrChannelSubState && isConnected) {
              if (diff > awaitIrrResponseDuration) {
                _sendIrrigationCommand(widget.deviceID, isIrrigating() ? 0 : 1);
              }
            }
          },
          child: button,
        ),
        const SizedBox(width: 15),
        text
      ],
    );
  }
}
