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
  final Logs _logs = Logs(tag: 'devices.dart');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.watch<UiProvider>().isDark
          ? const Color.fromRGBO(14, 14, 14, 1)
          : const Color.fromRGBO(230, 230, 230, 1),
      appBar: AppBar(
          backgroundColor: Colors.transparent,
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
      )
    );
  }

  Widget _buildList({
    required Map<String, SinkNode> sinkNodeMap,
    required Map<String, SensorNode> sensorNodeMap,
    required Map<String, bool Function(Widget)> options,}){

    return SingleChildScrollView(
      child: Column(
        children: [
          ..._buildCards(
            sinkNodeMap: sinkNodeMap,
            sensorNodeMap: sensorNodeMap,
            options: options
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCards({
    required Map<String, SinkNode> sinkNodeMap,
    required Map<String, SensorNode> sensorNodeMap,
    required Map<String, bool Function(Widget)> options}){

    List<Widget> cards = [];
    List<String> sinkNodeMapKeys = sinkNodeMap.keys.toList();

    for (String sinkId in sinkNodeMapKeys) {
      cards.add(
        SinkNodeCard(
          deviceInfo: sinkNodeMap[sinkId]!,
          bottomMargin: 15,
          expanded: false,
        ),
      );
      for (String sensorId in sinkNodeMap[sinkId]!.registeredSensorNodes) {
        cards.add(
          SensorNodeCard(
            deviceInfo: sensorNodeMap[sensorId]!,
            bottomMargin: 15,
          )
        );
      }
    }

    return cards.where((card) {
      return options.keys
          .map((optionKey) => options[optionKey]!(card))
          .any((result) => result);
    }).toList();
  }
}
