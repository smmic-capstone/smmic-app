import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smmic/components/devices/cards/sensor_node_card.dart';
import 'package:smmic/components/devices/cards/sink_node_card.dart';
import 'package:smmic/components/devices/bottom_drawer.dart';
import 'package:smmic/models/device_data_models.dart';
import 'package:smmic/pages/dashboard.dart';
import 'package:smmic/pages/devices_subpages/sensor_node_subpage.dart';
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor = context.watch<UiProvider>().isDark ? Colors.black : Colors.white;

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
      body: _buildList(
        sinkNodeList: context.watch<DevicesProvider>().sinkNodeList,
        sensorNodeList: context.watch<DevicesProvider>().sensorNodeList,
        options: context.watch<DeviceListOptionsNotifier>().enabledConditions,
        seSnapShotMap: context.watch<DevicesProvider>().sensorNodeSnapshotMap,
      )
    );
  }

  Widget _buildList({
    required List<SinkNode> sinkNodeList,
    required List<SensorNode> sensorNodeList,
    required Map<String, bool Function(Widget)> options,
    required Map<String, SensorNodeSnapshot> seSnapShotMap}){

    return SingleChildScrollView(
      child: Column(
        children: [
          ..._buildCards(
            sinkNodeList: sinkNodeList,
            sensorNodeList: sensorNodeList,
            options: options,
            seSnapshotMap: seSnapShotMap
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCards({
    required List<SinkNode> sinkNodeList,
    required List<SensorNode> sensorNodeList,
    required Map<String, bool Function(Widget)> options,
    required Map<String, SensorNodeSnapshot> seSnapshotMap}){

    List<Widget> cards = [];
    for (int i = 0; i < sinkNodeList.length; i++) {
      cards.add(SinkNodeCard(deviceInfo: sinkNodeList[i]));

      //List<SensorNode> sensorGroup = sensorNodeList.where((item) => item.registeredSinkNode == sinkNodeList[i].deviceID).toList();
      for (int x = 0; x < sensorNodeList.length; x++) {
        if (sensorNodeList[x].registeredSinkNode == sinkNodeList[i].deviceID) {
          SensorNodeSnapshot deviceSnapshot = seSnapshotMap[sensorNodeList[x].deviceID] ?? SensorNodeSnapshot.placeHolder(deviceId: sensorNodeList[x].deviceID);
          cards.add(SensorNodeCard(deviceInfo: sensorNodeList[x], deviceSnapshot: deviceSnapshot)
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

  void _updateProviders({required BuildContext context, required var data}) {
    WidgetsFlutterBinding.ensureInitialized();
    if (data is SensorNodeSnapshot) {
      context.read<DevicesProvider>().setNewSensorSnapshot(data);
    } else if (data is SMAlerts) {
      // TODO: handle from alerts
    } else if (data is String) {
      context.read<DevicesProvider>().setNewSensorSnapshot(data);
    }
    return;
  }
}
