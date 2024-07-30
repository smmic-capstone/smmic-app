import 'package:flutter/material.dart';
<<<<<<<< HEAD:lib/components/devices/sensor_node_card_expanded.dart
import 'package:smmic/models/device_data_models.dart';
import 'package:smmic/services/datetime_formatting.dart';
import 'package:smmic/services/devices/sensor_data.dart';
========
import 'package:smmic/services/datetime_formatting.dart';
>>>>>>>> 18d9102da2af79d20a0c1a725e14a976a0241be5:lib/components/devices/details_card.dart
import 'package:smmic/subcomponents/devices/battery_level.dart';
import 'package:smmic/subcomponents/devices/gauge.dart';

class DetailsCard extends StatefulWidget {
  const DetailsCard({super.key});

  @override
  State<DetailsCard> createState() => _DetailsCardState();
}

<<<<<<<< HEAD:lib/components/devices/sensor_node_card_expanded.dart
class _SensorNodeCardExpandedState extends State<SensorNodeCardExpanded> {

  late SensorNodeSnapshot _sensorNodeSnapshot;

  @override
  void initState() {
    super.initState();
    //TODO: assign proper id variable for 'getSnapshot', preferably move this out of the initState() function too
    _sensorNodeSnapshot = SensorNodeDataServices().getSnapshot(widget.deviceID);
  }
========
class _DetailsCardState extends State<DetailsCard> {
>>>>>>>> 18d9102da2af79d20a0c1a725e14a976a0241be5:lib/components/devices/details_card.dart

  final DatetimeFormatting _dateTimeFormatting = DatetimeFormatting();
  final Map<String, dynamic> _mockDataSnapshot = {
    'id': 'SEx0e9bmweebii5y',
    'deviceName': 'DEVICE 102',
    'batteryLevel': 64,
    'soilMoisture': 15,
    'temperature': 24,
    'humidity': 45,
    'timeStamp': DateTime.now()
  };

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
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
                    batteryLevel: _mockDataSnapshot['batteryLevel'],
                    alignmentAdjust: 1,
                    shrinkPercentSign: false
                  ),
                  Text(
                    _dateTimeFormatting.formatTime(_mockDataSnapshot['timeStamp']),
                    style: const TextStyle(fontFamily: 'Inter', fontSize: 20)
                  )
                ],
              ),
            )
          ),
          Expanded(
            flex: 4,
            child: RadialGauge(
              data: 'sm',
              value: _mockDataSnapshot['soilMoisture'] * 1.0,
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
                      data: 'tm',
                      value: _mockDataSnapshot['temperature'].toDouble(),
                      limit: 100,
                      radiusMultiplier: 0.9,
                    ),
                  ),
                  SizedBox(
                    width: 160,
                    child: RadialGauge(
                      data: 'hm',
                      value: _mockDataSnapshot['humidity'].toDouble(),
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
