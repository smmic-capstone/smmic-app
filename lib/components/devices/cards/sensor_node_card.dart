import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smmic/constants/api.dart';
import 'package:smmic/models/device_data_models.dart';
import 'package:smmic/pages/devices_subpages/sensor_node_subpage.dart';
import 'package:smmic/providers/theme_provider.dart';
import 'package:smmic/sqlitedb/db.dart';
import 'package:smmic/subcomponents/devices/battery_level.dart';
import 'package:smmic/subcomponents/devices/device_name.dart';
import 'package:smmic/subcomponents/devices/digital_display.dart';
import 'package:smmic/subcomponents/devices/gauge.dart';
import 'package:smmic/utils/api.dart';
import 'package:smmic/providers/devices_provider.dart';
import '../../../subcomponents/devices/device_dialog.dart';
import 'package:smmic/utils/logs.dart';

class SensorNodeCard extends StatefulWidget {
  const SensorNodeCard({super.key, required this.deviceInfo});

  final SensorNode deviceInfo;

  @override
  State<SensorNodeCard> createState() => _SensorNodeCardState();
}

class _SensorNodeCardState extends State<SensorNodeCard> with AutomaticKeepAliveClientMixin {

  final ApiRequest _apiRequest = ApiRequest();
  final ApiRoutes _apiRoutes = ApiRoutes();
  final Logs _logs = Logs(tag: 'Sensor Node Card()');
  final StreamController<SensorNodeSnapshot> _streamController = StreamController<SensorNodeSnapshot>.broadcast();
  StreamController<SensorNodeSnapshot> get streamController => _streamController;
  Stream<SensorNodeSnapshot> get readingsStream => _streamController.stream;
 /* late Stream<SensorNodeSnapshot> readingsStream;*/
  SensorNodeSnapshot? cardReadings;
  SensorNodeSnapshot? sqlCardReadings;

  @override
  void initState(){
    super.initState();
    /*readingsStream = streamController.stream.asBroadcastStream();*/
    _apiRequest.channelConnect(route: _apiRoutes.getSNReadings, controller: streamController, deviceID: widget.deviceInfo.deviceID);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final DeviceDialog _skDeviceDialog = DeviceDialog(
        context: context,
        deviceID: widget.deviceInfo.deviceID,
        latitude: widget.deviceInfo.latitude,
        longitude: widget.deviceInfo.longitude);

    return GestureDetector(
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (context) {
        return SensorNodePage(
            deviceID: widget.deviceInfo.deviceID,
            latitude: widget.deviceInfo.latitude,
            longitude: widget.deviceInfo.longitude,
            deviceName: widget.deviceInfo.deviceName,
          streamController: streamController,);
      })),
      child: Stack(
        children: [
          Container(
              margin: const EdgeInsets.only(left: 25, right: 25, bottom: 15),
              padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 18),
              decoration: BoxDecoration(
                  color: context.watch<UiProvider>().isDark
                      ? Colors.black
                      : Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                  boxShadow: [
                    BoxShadow(
                        color: context.watch<UiProvider>().isDark
                            ? Colors.white.withOpacity(0.09)
                            : Colors.black.withOpacity(0.09),
                        spreadRadius: 0,
                        blurRadius: 4,
                        offset: const Offset(0, 4))
                  ]),
              height: 160,
              child: FutureBuilder(
                future: DatabaseHelper.getAllReadings(widget.deviceInfo.deviceID),
                builder: (context, futureSnapshot) {
                  _logs.info(message: "Got Data from SQFLITE: $futureSnapshot");
                  sqlCardReadings = futureSnapshot.data;
                  return StreamBuilder<SensorNodeSnapshot>(
                    stream: readingsStream,
                    initialData: futureSnapshot.data,
                    builder: (context, snapshot){
                      if(snapshot.hasData && snapshot.data?.deviceID == widget.deviceInfo.deviceID){
                        cardReadings = snapshot.data;
                      }
                      final batteryLevel = cardReadings?.batteryLevel ?? sqlCardReadings?.batteryLevel ?? 00;
                      final humidity = cardReadings?.humidity ?? sqlCardReadings?.humidity ?? 00;
                      final temperature = cardReadings?.temperature ?? sqlCardReadings?.temperature ?? 00;
                      final soilMoisture = cardReadings?.soilMoisture ?? sqlCardReadings?.soilMoisture ?? 00;
                      return Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Column(
                              children: [
                                Expanded(
                                    flex: 3,
                                    child: DeviceName(
                                        deviceName: widget.deviceInfo
                                            .deviceName)),
                                Expanded(
                                  flex: 1,
                                  //TODO: add snapshot data here
                                  child: BatteryLevel(batteryLevel: batteryLevel),
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
                                      mainAxisAlignment: MainAxisAlignment
                                          .spaceAround,
                                      children: [
                                        DigitalDisplay(
                                          //TODO: add snapshot data here
                                          value: temperature,
                                          valueType: 'temperature',
                                        ),
                                        DigitalDisplay(
                                          //TODO: add snapshot data here
                                          value: humidity,
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
                                            //TODO: add snapshot data here
                                            value:  soilMoisture,
                                            limit: 100)),
                                  )
                                ],
                              )),
                        ],
                      );
                    }
                  );
                }
              )
          ),
          Container(
            padding: const EdgeInsets.only(right: 37, top: 12),
            alignment: Alignment.topRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                RotatedBox(
                  quarterTurns: 2,
                  child: IconButton(
                    icon: const Icon(
                      CupertinoIcons.pencil_circle,
                      size: 20,
                    ),
                    color: context.watch<UiProvider>().isDark
                        ? Colors.white.withOpacity(0.30)
                        : Colors.black.withOpacity(0.30),
                    onPressed: () {
                      _skDeviceDialog.renameSNDialog();
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
                RotatedBox(
                  quarterTurns: 2,
                  child: Icon(
                    CupertinoIcons.arrow_down_left_circle,
                    size: 20,
                    color: context.watch<UiProvider>().isDark
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
