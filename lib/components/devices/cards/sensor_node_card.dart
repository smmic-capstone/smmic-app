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

  final StreamController<SensorNodeSnapshot> _snapshotStreamController = StreamController<SensorNodeSnapshot>.broadcast();
  final StreamController<SMAlerts> _alertsStreamController = StreamController<SMAlerts>.broadcast();

  StreamController<SMAlerts> get smStreamController => _alertsStreamController;
  StreamController<SensorNodeSnapshot> get streamController => _snapshotStreamController;

  SensorNodeSnapshot? cardReadings;
  SensorNodeSnapshot? sqlCardReadings;
  SMAlerts? alertsStreamData;

  Color? tempColor;
  Color? moistureColor;
  Color? humidityColor;

  int? tempAlert;
  int? humidityAlert;
  int? moistureAlert;

  @override
  void initState(){
    super.initState();
    context.read<DevicesProvider>().deviceReadings(widget.deviceInfo.deviceID);
    _apiRequest.channelReadings(route: _apiRoutes.getSMAlerts, controller: smStreamController, deviceID: widget.deviceInfo.deviceID, context: context);
    _apiRequest.channelConnect(route: _apiRoutes.getSNReadings, controller: streamController, deviceID: widget.deviceInfo.deviceID);
  }

  @override
  void dispose() {
    _snapshotStreamController.close();
    _alertsStreamController.close();
    super.dispose();
  }


  Color _getColor(int? alertCode, Map<int,Color> colorMap){
    return colorMap[alertCode] ?? Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final DeviceDialog _skDeviceDialog = DeviceDialog(
        context: context,
        deviceID: widget.deviceInfo.deviceID,
        latitude: widget.deviceInfo.latitude,
        longitude: widget.deviceInfo.longitude
    );

    return GestureDetector(
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (context) {
        return SensorNodePage(
            deviceID: widget.deviceInfo.deviceID,
            latitude: widget.deviceInfo.latitude,
            longitude: widget.deviceInfo.longitude,
            deviceName: widget.deviceInfo.deviceName,
            deviceInfo: widget.deviceInfo,
            streamController: streamController,);
      })),
      child: Stack(
        children: [
          Container(
              margin: const EdgeInsets.only(left: 25, right: 25, bottom: 15),
              padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 18),
              decoration: BoxDecoration(
                  color: context.watch<UiProvider>().isDark ? Colors.black : Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                  boxShadow: [
                    BoxShadow(
                        color: context.watch<UiProvider>().isDark ? Colors.white.withOpacity(0.09) : Colors.black.withOpacity(0.09),
                        spreadRadius: 0,
                        blurRadius: 4,
                        offset: const Offset(0, 4))
                  ]),
              height: 160,
              child:StreamBuilder<SensorNodeSnapshot>(
                    stream: _snapshotStreamController.stream,
                    builder: (context, snapshot){
                      sqlCardReadings = context.watch<DevicesProvider>().sensorNodeSnapshotList.firstWhere((sensorNode) => sensorNode?.deviceID == widget.deviceInfo.deviceID,
                          orElse: () => SensorNodeSnapshot.fromJSON({
                            'device_id' : widget.deviceInfo.deviceID,
                            'timestamp' : DateTime.now().toString(),
                            'soil_moisture' : 00,
                            'temperature' : 00,
                            'humidity' : 00,
                            'battery_level' : 00
                          }));

                      if(snapshot.hasData && snapshot.data?.deviceID == widget.deviceInfo.deviceID){
                        cardReadings = snapshot.data;
                      }

                      return StreamBuilder<SMAlerts>(
                        stream: _alertsStreamController.stream,
                        builder: (context, alertsSnapshot) {
                          _logs.info(message: "alertSnapshot deviceID = ${alertsSnapshot.data?.deviceID} == widget Device ID = ${widget.deviceInfo.deviceID}");

                          if(alertsSnapshot.hasData && alertsSnapshot.data?.deviceID == widget.deviceInfo.deviceID){

                            alertsStreamData = alertsSnapshot.data;

                            _logs.info(message: "alertsStreamData message : ${alertsStreamData?.alerts}");

                            /*if(alertsStreamData!.alerts >= 20 && alertsStreamData!.alerts < 30){
                              humidityAlert =  alertsStreamData!.alerts;
                            }else if(alertsStreamData!.alerts >= 30 && alertsStreamData!.alerts < 40){
                              tempAlert =  alertsStreamData!.alerts;
                            }else if(alertsStreamData!.alerts >= 40 && alertsStreamData!.alerts < 50){
                              moistureAlert =  alertsStreamData!.alerts;
                            }*/
                            String? deviceID = context.watch<DevicesProvider>().alertCode?.deviceID;

                            if (deviceID == widget.deviceInfo.deviceID) {
                              tempAlert = context.watch<DevicesProvider>().tempAlert?.alerts;
                              moistureAlert = context.watch<DevicesProvider>().moistureAlert?.alerts;
                              humidityAlert = context.watch<DevicesProvider>().humidityAlert?.alerts;
                              
                              tempColor = _getColor(tempAlert, {30: Colors.red, 31: Colors.green, 32: Colors.blue,});
                              moistureColor = _getColor(moistureAlert, {40: Colors.red, 41: Colors.green, 42: Colors.blue});
                              humidityColor = _getColor(humidityAlert, {20: Colors.red, 21: Colors.green, 22: Colors.blue});
                            }
                          }

                          final batteryLevel = cardReadings?.batteryLevel ?? sqlCardReadings?.batteryLevel ?? 00;
                          final humidity = alertsStreamData?.data['humidity'] ?? cardReadings?.humidity ?? sqlCardReadings?.humidity ?? 00;
                          final temperature = alertsStreamData?.data['temperature'] ?? cardReadings?.temperature ?? sqlCardReadings?.temperature ?? 00;
                          final soilMoisture = alertsStreamData?.data['soil_moisture'] ?? cardReadings?.soilMoisture ?? sqlCardReadings?.soilMoisture ?? 00;

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
                                      child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Icon(Icons.device_thermostat_outlined,color: tempColor,),
                                              Icon(Icons.water_drop_outlined, color: moistureColor),
                                              Icon(Icons.water, color: humidityColor,)
                                            ],
                                          )
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
                  ),
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
