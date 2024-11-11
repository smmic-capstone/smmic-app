import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smmic/components/devices/cards/sensor_node_card.dart';
import 'package:smmic/components/devices/cards/sink_node_card.dart';
import 'package:smmic/components/devices/bottom_drawer.dart';
import 'package:smmic/models/device_data_models.dart';
import 'package:smmic/pages/dashboard.dart';
import 'package:smmic/providers/device_settings_provider.dart';
import 'package:smmic/providers/devices_provider.dart';
import 'package:smmic/providers/theme_provider.dart';
import 'package:smmic/services/devices_services.dart';
import 'package:smmic/services/user_data_services.dart';
import 'package:smmic/sqlitedb/db.dart';
import 'package:smmic/utils/logs.dart';
import '../constants/api.dart';
import '../utils/api.dart';

class Devices extends StatefulWidget {
  const Devices({super.key});

  @override
  State<Devices> createState() => _Devices();
}

class _Devices extends State<Devices> {
  //TODO: assign theme

  final Logs _logs = Logs(tag: 'devices.dart');

  final UserDataServices _userDataServices = UserDataServices();
  final DevicesServices _devicesServices = DevicesServices();
  final ApiRequest _apiRequest = ApiRequest();
  final ApiRoutes _apiRoutes = ApiRoutes();
  final DevicesProvider _devicesProvider = DevicesProvider();

  // merged stream group
  // TODO: wrap `mergedStream` inside a provider

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor = context.watch<UiProvider>().isDark ? Colors.black : Colors.white;
    late final Stream mergedStream;

    mergedStream = StreamGroup.merge([
      context.watch<DevicesProvider>().seSnapshotStreamController!.stream,
      context.watch<DevicesProvider>().alertsStreamController!.stream,
      context.watch<DevicesProvider>().mqttStreamController!.stream,
    ]);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
          backgroundColor: bgColor,
          title: const Text('Devices'),
          centerTitle: true,
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 10),
              child: BottomDrawerButton(),
            )
          ]
      ),
      body: StreamBuilder(
          stream: mergedStream,
          builder: (context, snapshot) {

            // check for data from streams
            if (snapshot.hasData) {
              _updateProviders(
                  context: context,
                  data: snapshot.data
              );
            } else if (snapshot.hasError) {
              // TODO: show err message
            }
            return _buildList(
                sinkNodeList: context.watch<DevicesProvider>().sinkNodeList,
                sensorNodeList: context.watch<DevicesProvider>().sensorNodeList,
                options: context.watch<DeviceListOptionsNotifier>().enabledConditions
            );
          }
      )
    );
  }

  void _updateProviders({required BuildContext context, required var data}) {
    WidgetsFlutterBinding.ensureInitialized();
    if (data is SensorNodeSnapshot) {
      context.read<DevicesProvider>().setNewSensorSnapshot(data);
    } else if (data is SMAlerts) {
      // TODO: handle from alerts
    } else if (data is String) {
      // TODO: handle from mqtt
    }
    return;
  }

  Widget _buildList({
    required List<SinkNode> sinkNodeList,
    required List<SensorNode> sensorNodeList,
    required Map<String, bool Function(Widget)> options}){

    return ListView(
      shrinkWrap: true,
      addAutomaticKeepAlives: true,
      children: [
        ..._buildCards(
          sinkNodeList: sinkNodeList,
          sensorNodeList: sensorNodeList,
          options: options
        ),
      ],
    );
  }

  List<Widget> _buildCards({
    required List<SinkNode> sinkNodeList,
    required List<SensorNode> sensorNodeList,
    required Map<String, bool Function(Widget)> options}){

    List<Widget> cards = [];
    for (int i = 0; i < sinkNodeList.length; i++) {
      cards.add(SinkNodeCard(deviceInfo: sinkNodeList[i]));
      //List<SensorNode> sensorGroup = sensorNodeList.where((item) => item.registeredSinkNode == sinkNodeList[i].deviceID).toList();
      for (int x = 0; x < sensorNodeList.length; x++) {
        if (sensorNodeList[x].registeredSinkNode == sinkNodeList[i].deviceID) {
          cards.add(SensorNodeCard(deviceInfo: sensorNodeList[x])
          );
        }
      }
    }
    return cards.where((card) {
      return options.keys
          .map((optionKey) => options[optionKey]!(card))
          .any((result) => result);
    }).toList();
  }
}
