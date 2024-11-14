import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smmic/components/devices/cards/sensor_node_card.dart';
import 'package:smmic/components/devices/cards/sink_node_card.dart';
import 'package:smmic/components/devices/bottom_drawer.dart';
import 'package:smmic/models/device_data_models.dart';
import 'package:smmic/providers/device_settings_provider.dart';
import 'package:smmic/providers/devices_provider.dart';
import 'package:smmic/providers/theme_provider.dart';
import 'package:smmic/utils/logs.dart';

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
        sinkNodeMap: context.watch<DevicesProvider>().sinkNodeMap,
        sensorNodeMap: context.watch<DevicesProvider>().sensorNodeMap,
        options: context.watch<DeviceListOptionsNotifier>().enabledConditions,
        seSnapShotMap: context.watch<DevicesProvider>().sensorNodeSnapshotMap,
      )
    );
  }

  Widget _buildList({
    required Map<String, SinkNode> sinkNodeMap,
    required Map<String, SensorNode> sensorNodeMap,
    required Map<String, bool Function(Widget)> options,
    required Map<String, SensorNodeSnapshot> seSnapShotMap}){

    return SingleChildScrollView(
      child: Column(
        children: [
          ..._buildCards(
            sinkNodeMap: sinkNodeMap,
            sensorNodeMap: sensorNodeMap,
            options: options,
            seSnapshotMap: seSnapShotMap
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCards({
    required Map<String, SinkNode> sinkNodeMap,
    required Map<String, SensorNode> sensorNodeMap,
    required Map<String, bool Function(Widget)> options,
    required Map<String, SensorNodeSnapshot> seSnapshotMap}){

    List<Widget> cards = [];
    List<String> sinkNodeMapKeys = sinkNodeMap.keys.toList();

    for (String sinkId in sinkNodeMapKeys) {
      cards.add(SinkNodeCard(deviceInfo: sinkNodeMap[sinkId]!));
      for (String sensorId in sinkNodeMap[sinkId]!.registeredSensorNodes) {
        cards.add(SensorNodeCard(
            deviceInfo: sensorNodeMap[sensorId]!,
            deviceSnapshot: seSnapshotMap[sensorId]
        ));
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
    } else if (data is SMSensorState) {
      // TODO: handle from alerts
    } else if (data is String) {
      context.read<DevicesProvider>().setNewSensorSnapshot(data);
    }
    return;
  }
}
