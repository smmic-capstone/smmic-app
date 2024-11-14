import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smmic/components/devices/sensor_node_subpage/stacked_line.dart';
import 'package:smmic/components/devices/sensor_node_subpage/sensor_node_card_expanded.dart';
import 'package:smmic/providers/devices_provider.dart';
import '../../models/device_data_models.dart';
import '../../subcomponents/devices/device_dialog.dart';

class SensorNodePage extends StatefulWidget {
  const SensorNodePage({
    super.key,
    required this.deviceID,
    this.latitude,
    this.longitude,
    required this.deviceName,
    required this.streamController,
    required this.deviceInfo
  });

  final String deviceID;
  final String? latitude;
  final String? longitude;
  final String deviceName;
  final SensorNode deviceInfo;
  final StreamController<SensorNodeSnapshot> streamController;


  @override
  State<StatefulWidget> createState() => _SensorNodePageState();
}

class _SensorNodePageState extends State<SensorNodePage> {

  @override
  Widget build(BuildContext context) {
    final DeviceDialog _deviceDialog = DeviceDialog(
        context: context,
        deviceID: widget.deviceInfo.deviceID,
        latitude: widget.deviceInfo.latitude,
        longitude: widget.deviceInfo.longitude);

    Color? bgColor = Color.fromRGBO(239, 239, 239, 1.0);
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: Text(widget.deviceInfo.deviceName),
        centerTitle: true,
        actions: [
          IconButton(
            padding: EdgeInsets.all(19),
            onPressed: () => {
              _deviceDialog.renameSNDialog()
            },
            icon: const Icon(Icons.edit_outlined, size: 21, color: Colors.black),
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.only(left: 25, right: 25),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // TODO:
              SensorNodeCardExpanded(
                deviceID: widget.deviceID,
                snapshot: context.watch<DevicesProvider>().sensorNodeSnapshotMap[widget.deviceID],
                streamController: widget.streamController.stream
              ),
              Container(
                margin: EdgeInsets.only(bottom: 25),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          spreadRadius: 0,
                          blurRadius: 4,
                          offset: Offset(0, 4)
                      )
                    ]
                ),
                height: 315,
                child: StackedLineChart(deviceID: widget.deviceID),
              ),
            ],
          ),
        ),
      )
    );
  }
}