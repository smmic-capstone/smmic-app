import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:smmic/components/bottomnavbar/bottom_nav_bar.dart';
import 'package:smmic/models/device_data_models.dart';
import 'package:smmic/providers/devices_provider.dart';
import 'package:smmic/services/devices_services.dart';
import 'package:smmic/sqlitedb/db.dart';
import 'package:smmic/subcomponents/devices/digital_display.dart';
import 'package:smmic/utils/datetime_formatting.dart';
import 'package:smmic/utils/device_utils.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class StackedLineChart extends StatefulWidget {
  const StackedLineChart({
    super.key,
    required this.deviceId
  });
  final String deviceId;

  @override
  State<StackedLineChart> createState() => _StackedLineChartState();
}

class _StackedLineChartState extends State<StackedLineChart> {
  final DeviceUtils _deviceUtils = DeviceUtils();
  final DateTimeFormatting _dateTimeFormatting = DateTimeFormatting();

  final ScrollController _stackedLinesScrollController = ScrollController();
  bool _showRelativeTimeDisplay = false; //ignore: prefer_final_fields

  void _relativeTimeDisplayTrigger() {
    if (_stackedLinesScrollController.position.maxScrollExtent
        - _stackedLinesScrollController.offset < 15) {
      setState(() {
        _showRelativeTimeDisplay = true;
      });
    } else if (_stackedLinesScrollController.position.maxScrollExtent
        - _stackedLinesScrollController.offset > 15) {
      setState(() {
        _showRelativeTimeDisplay = false;
      });
    }
  }

  void _stackedLineSnapToOffset(double snapOffset) {
    double currentOffset = _stackedLinesScrollController.offset;
    double snapPoint = (currentOffset / snapOffset).round() * snapOffset;
    _stackedLinesScrollController.animateTo(
        snapPoint,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutExpo
    );
  }

  Color? _generateColor(String name) {
    if (name == 'soil moisture') {
      return Colors.amber;
    }
    if (name == 'humidity') {
      return Colors.blue;
    }
    if (name == 'temperature') {
      return Colors.deepOrange;
    }
    return null;
  }

  int _scaleTemp(int temp) {
    //TODO: format this variable so it aligns with the chart
    return (temp * 1.5).toInt();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _stackedLinesScrollController.jumpTo(
          _stackedLinesScrollController.position.maxScrollExtent
      );
    });
    _stackedLinesScrollController.addListener(_relativeTimeDisplayTrigger);
    super.initState();
  }

  @override
  void dispose() {
    _stackedLinesScrollController.removeListener(_relativeTimeDisplayTrigger);
    _stackedLinesScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double stackedLineSnapOffset = (MediaQuery.of(context).size.width / 6) - 15.5;

    List<SensorNodeSnapshot> chartData = context.watch<DevicesProvider>()
        .sensorNodeChartDataMap[widget.deviceId] ?? [];
    return Stack(
      children: [
        _backGround(),
        _buildStaticTickLines(),
        _buildStackedLines(chartData, stackedLineSnapOffset),
        _buildLegends(),
        _relativeToNowDisplay()
      ],
    );
  }

  Widget _backGround() {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(25)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: Colors.black.withOpacity(0.5),
          height: 300,
        ),
      ),
    );
  }

  Widget _buildLegends() {
    List<String> legends = ['Soil Moisture', 'Temperature', 'Humidity'];
    return Positioned(
      bottom: 50,
      left: 45,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...legends.map((legend) {
            return SizedBox(
              height: 20,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                        color: _generateColor(legend.toLowerCase())!.withOpacity(0.5),
                        borderRadius: const BorderRadius.all(Radius.circular(50))
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    legend,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w400
                    ),
                  )
                ],
              ),
            );
          })
        ],
      ),
    );
  }

  Widget _buildStackedLines(List<SensorNodeSnapshot> chartData, double snapOffset) {
    return Container(
      padding: const EdgeInsets.only(top: 50, right: 36),
      height: 175,
      child: Listener(
        onPointerUp: (_) => _stackedLineSnapToOffset(snapOffset),
        child: SingleChildScrollView(
          physics: chartData.length < 6
              ? const NeverScrollableScrollPhysics()
              : const AlwaysScrollableScrollPhysics(),
          controller: _stackedLinesScrollController,
          scrollDirection: Axis.horizontal,
          child: Container(
            width: 500,
            margin: const EdgeInsets.only(left: 39),
            child: SfCartesianChart(
                plotAreaBorderWidth: 0.0,
                primaryXAxis: const CategoryAxis(
                  rangePadding: ChartRangePadding.none,
                  axisLine: AxisLine(
                      color: Colors.transparent
                  ),
                  labelStyle: TextStyle(fontSize: 0, color: Colors.transparent),
                  tickPosition: TickPosition.inside,
                  isVisible: false,
                  labelPlacement: LabelPlacement.onTicks,
                ),
                primaryYAxis: const NumericAxis(
                  maximum: 100,
                  minimum: 0,
                  isVisible: false,
                ),
                series: <CartesianSeries>[
                  ..._buildLines(chartData)
                ]
            ),
          ),
        ),
      ),
    );
  }

  List<CartesianSeries> _buildLines(List<SensorNodeSnapshot> chartData) {
    List<CartesianSeries> cartesianSeriesList = [];
    List<SensorNodeSnapshot?> cData = chartData.map((element) => element).toList();
    cData = List<SensorNodeSnapshot?>.generate(
        DatabaseHelper.maxChartLength - chartData.length, (index) => null) + cData;
    for (ValueType field in ValueType.values.toList()) {
      int increment = 0;
      cartesianSeriesList.add(
        StackedLineSeries<SensorNodeSnapshot?, String>(
            markerSettings: MarkerSettings(
                color: _generateColor(field.name),
                isVisible: true,
                height: 6,
                width: 6
            ),
            dataLabelSettings: DataLabelSettings(
                isVisible: false
            ),
            animationDuration: 500,
            color: _generateColor(field.name),
            groupName: field.name,
            dataSource: cData,
            xValueMapper: (SensorNodeSnapshot? data, _) {
              increment++;
              if (data != null) {
                return _dateTimeFormatting.formatTimeClearZero(data.timestamp);
              } else {
                return _dateTimeFormatting.formatTimeClearZero(
                    DateTime.fromMillisecondsSinceEpoch(0).add(
                        Duration(hours: increment)
                    )
                );
              }
            },
            yValueMapper: (SensorNodeSnapshot? data, _) {
              if (data != null) {
                if (field.name == ValueType.soilMoisture.name) {
                  return data.soilMoisture;
                } else if (field.name == ValueType.temperature.name) {
                  return _scaleTemp(data.temperature.toInt());
                } else if (field.name == ValueType.humidity.name) {
                  return data.humidity;
                }
              }
              return null;
            }
        ),
      );
    }
    return cartesianSeriesList;
  }

  Widget _relativeToNowDisplay() {
    return Positioned(
      bottom: 65,
      right: 53 - 10.5,
      child: AnimatedOpacity(
        opacity: _showRelativeTimeDisplay ? 1 : 0,
        duration: const Duration(milliseconds: 300),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 7
              ),
              child: StreamBuilder(
                  stream: _deviceUtils.timeTickerSeconds(),
                  builder: (context, snapshot) {
                    return Text(
                      _deviceUtils.relativeTimeDisplay(
                          context.watch<DevicesProvider>()
                              .sensorNodeChartDataMap[widget.deviceId]!.last.timestamp,
                          snapshot.data ?? DateTime.now()
                      ),
                      style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w500
                      ),
                    );
                  }
              ),
            ),
            //const SizedBox(width: 5),
            Container(
              color: Colors.white,
              width: 10,
              height: 1,
            ),
            Container(
              height: 6,
              width: 6,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(50))
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStaticTickLines() {
    List<SensorNodeSnapshot?> nullChart = List<SensorNodeSnapshot?>.generate(6, (index) => null);
    int increment = 0;
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(1),
          ],
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcIn, // Ensures the gradient fills the child.
      child: Container(
        padding: const EdgeInsets.only(top: 40, right: 35),
        height: 265,
        width: 600,
        margin: const EdgeInsets.only(left: 39.2),
        child: SfCartesianChart(
            plotAreaBorderWidth: 0.0,
            primaryXAxis: const CategoryAxis(
              majorGridLines: MajorGridLines(
                width: 1
              ),
              majorTickLines: MajorTickLines(
                width: 0
              ),
              axisLine: AxisLine(color: Colors.transparent),
              tickPosition: TickPosition.inside,
              isVisible: true,
              labelPlacement: LabelPlacement.onTicks,
              labelStyle: TextStyle(
                  fontSize: 0,
                  color: Colors.transparent
              ),
            ),
            primaryYAxis: const NumericAxis(
              isVisible: false,
            ),
            series: <CartesianSeries>[
              StackedLineSeries<SensorNodeSnapshot?, String>(
                  animationDuration: 500,
                  dataSource: nullChart,
                  xValueMapper: (SensorNodeSnapshot? data, _) {
                    increment += 1;
                    return _dateTimeFormatting.formatTimeClearZero(
                        DateTime.fromMillisecondsSinceEpoch(0).add(
                            Duration(hours: increment)
                        )
                    );
                  },
                  yValueMapper: (SensorNodeSnapshot? data, _) {
                    return null;
                  }
              ),
            ]
        ),
      ),
    );

  }
}