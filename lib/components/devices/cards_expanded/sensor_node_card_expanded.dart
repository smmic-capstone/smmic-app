import 'package:flutter/material.dart';
import 'package:smmic/models/devices/sensor_node_data_model.dart';
import 'package:smmic/services/datetime_formatting.dart';
import 'package:smmic/services/devices/sensor_node_data_services.dart';
import 'package:smmic/subcomponents/devices/battery_level.dart';
import 'package:smmic/subcomponents/devices/gauge.dart';

class SensorNodeCardExpanded extends StatefulWidget {
  const SensorNodeCardExpanded({super.key, required this.deviceID});

  final String deviceID;

  @override
  State<SensorNodeCardExpanded> createState() => _SensorNodeCardExpandedState();
}

class _SensorNodeCardExpandedState extends State<SensorNodeCardExpanded> {

  late SensorNodeData _sensorNodeSnapshot;

  @override
  void initState() {
    super.initState();
    //TODO: assign proper id variable for 'getSnapshot', preferably move this out of the initState() function too
    _sensorNodeSnapshot = SensorNodeDataServices().getSnapshot(widget.deviceID);
  }

  final DatetimeFormatting _dateTimeFormatting = DatetimeFormatting();
  // final SensorNodeDataServices _sensorDataServices = SensorNodeDataServices();

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      height: 450,
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
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BatteryLevel(
                    batteryLevel: _sensorNodeSnapshot.batteryLevel.toInt(),
                    alignmentAdjust: 1,
                    shrinkPercentSign: false
                  ),
                  Text(
                    _dateTimeFormatting.formatTime(_sensorNodeSnapshot.timestamp),
                    style: const TextStyle(fontFamily: 'Inter', fontSize: 20)
                  )
                ],
              ),
            )
          ),
          Expanded(
            flex: 4,
            child: RadialGauge(
              valueType: 'soilMoisture',
              value: _sensorNodeSnapshot.soilMoisture,
              limit: 100,
              scaleMultiplier: 1.5
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 160,
                    child: RadialGauge(
                      valueType: 'temperature',
                      value: _sensorNodeSnapshot.temperature,
                      limit: 100,
                      radiusMultiplier: 0.9,
                    ),
                  ),
                  SizedBox(
                    width: 160,
                    child: RadialGauge(
                      valueType: 'humidity',
                      value: _sensorNodeSnapshot.humidity,
                      limit: 100,
                      radiusMultiplier: 0.9,
                    ),
                  ),
                ],
              ),
            )
          )
        ],
      ),
    );
  }
}
