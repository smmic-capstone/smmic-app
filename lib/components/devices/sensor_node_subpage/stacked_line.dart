import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:smmic/models/device_data_models.dart';
import 'package:smmic/providers/devices_provider.dart';
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

class _StackedLineChartState extends State<StackedLineChart> with TickerProviderStateMixin {
  // helpers, configs
  final DeviceUtils _deviceUtils = DeviceUtils();
  final DateTimeFormatting _dateTimeFormatting = DateTimeFormatting();

  // widget variables
  final ScrollController _stackedLinesScrollController = ScrollController();
  //final ScrollController _magicStackedLineScrollController = ScrollController();
  bool _showRelativeTimeDisplay = false; //ignore: prefer_final_fields
  int _highLightedPointIndex = -1; // ignore: prefer_final_fields
  double _calculatedOffset = 0; // ignore: prefer_final_fields

  // focused value variables
  late AnimationController _valuesAnimationController;
  late Animation<double> _soilMoistureAnimation;
  final Tween<double> _soilMoistureTween = Tween<double>(begin: 0, end: 0);
  late Animation<double> _temperatureAnimation;
  final Tween<double> _temperatureTween = Tween<double>(begin: 0, end: 0);
  late Animation<double> _humidityAnimation;
  final Tween<double> _humidityTween = Tween<double>(begin: 0, end: 0);
  late List<Animation<double>> _valuesAnimationList;
  double _focusedPointSoilMoisture = 0; // ignore: prefer_final_fields
  double _focusedPointTemperature = 0; // ignore: prefer_final_fields
  double _focusedPointHumidity = 0; // ignore: prefer_final_fields
  late Animation _indicatorLineAnimation;

  void _focusedPointTrigger() {
    if (_highLightedPointIndex != -1) {
      setState(() {
        _soilMoistureTween.end = _focusedPointSoilMoisture;
        _temperatureTween.end = _focusedPointTemperature;
        _humidityTween.end = _focusedPointHumidity;
        _valuesAnimationController.forward();
      });
      return;
    } else {
      setState(() {
        _valuesAnimationController.reset();
      });
    }
  }

  // triggers opacity of the relative time display
  void _relativeToNowOpacityTrigger() {
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
    setState(() {
      _calculatedOffset = snapPoint;
    });
    _stackedLinesScrollController.animateTo(
        snapPoint,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutExpo
    );
    //_magicStackedLineScrollController.jumpTo(_stackedLinesScrollController.offset);
    // _stackedLinesScrollController.jumpTo(snapPoint);
  }

  Color? _generateColor(String name) {
    if (name == 'soil moisture') {
      return Colors.amber;
    }
    if (name == 'humidity') {
      return const Color.fromRGBO(98, 245, 255, 1);
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
    // init animation variables
    _valuesAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(
          milliseconds: 500
      ),
    );
    _indicatorLineAnimation = Tween<double>(
      begin: 0,
      end: 25,
    ).animate(CurvedAnimation(
        parent: _valuesAnimationController,
        curve: Curves.easeInOutExpo
    ));
    _soilMoistureAnimation = _soilMoistureTween.animate(
        CurvedAnimation(
            parent: _valuesAnimationController,
            curve: Curves.easeInOutExpo
        )
    );
    _temperatureAnimation = _temperatureTween.animate(
        CurvedAnimation(
            parent: _valuesAnimationController,
            curve: Curves.easeInOutExpo
        )
    );
    _humidityAnimation = _humidityTween.animate(
        CurvedAnimation(
            parent: _valuesAnimationController,
            curve: Curves.easeInOutExpo
        )
    );
    _valuesAnimationList = [
      _soilMoistureAnimation,
      _temperatureAnimation,
      _humidityAnimation
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _stackedLinesScrollController.jumpTo(
          _stackedLinesScrollController.position.maxScrollExtent
      );
    });
    _stackedLinesScrollController.addListener(_relativeToNowOpacityTrigger);
    super.initState();
  }

  @override
  void dispose() {
    _stackedLinesScrollController.removeListener(_relativeToNowOpacityTrigger);
    _stackedLinesScrollController.dispose();
    _valuesAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double stackedLineSnapOffset = (MediaQuery.of(context).size.width / 6) - 15.5;

    List<SensorNodeSnapshot> chartData = context.watch<DevicesProvider>()
        .sensorNodeChartDataMap[widget.deviceId] ?? [];
    return Listener(
      onPointerUp: (_) {
        setState(() {
          _highLightedPointIndex = -1;
          _showRelativeTimeDisplay = _stackedLinesScrollController.position.maxScrollExtent
              - _stackedLinesScrollController.offset < 15;
        });
        _focusedPointTrigger();
      },
      child: Stack(
        children: [
          _islandBackground(),
          _staticTickLines(),
          _onFocusChartScaffold(chartData),
          _chartScaffold(chartData, stackedLineSnapOffset),
          Builder(
            builder: (context) {
              if (_highLightedPointIndex != -1) {
                int indexOffset = DatabaseHelper.maxChartLength - chartData.length;
                int finalIndex = _highLightedPointIndex - indexOffset;
                return _focusedPointValues(chartData[finalIndex]);
              } else {
                return _legends();
              }
            },
          ),
          _relativeToNowDisplay(),
        ],
      ),
    );
  }

  Widget _islandBackground() {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(25)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: Colors.black.withOpacity(0.6),
          height: 300,
        ),
      ),
    );
  }

  Widget _legends() {
    List<String> legends = ['Soil Moisture', 'Temperature', 'Humidity'];
    return Positioned(
      bottom: 60,
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

  Widget _focusedPointValues(SensorNodeSnapshot focusedData) {
    List<String> fields = ['soil moisture', 'temperature', 'humidity'];
    return Positioned(
      bottom: 65,
      left: 45,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...fields.indexed.map((field) {
            return Stack(
              children: [
                Positioned(
                  left: 0,
                  bottom: 3,
                  child: AnimatedBuilder(
                      animation: _indicatorLineAnimation,
                      builder: (context, child) {
                        return Container(
                          width: _indicatorLineAnimation.value,
                          height: 2,
                          decoration: BoxDecoration(
                              color: _generateColor(field.$2),
                              borderRadius: const BorderRadius.all(Radius.circular(25))
                          ),
                        );
                      }
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  height: 50,
                  width: 85,
                  child: AnimatedBuilder(
                      animation: _valuesAnimationList[field.$1],
                      builder: (context, child) {
                        String value = _valuesAnimationList[field.$1].value.toString();
                        return RichText(
                          text: TextSpan(
                              text: value.substring(0, value.length > 3 ? 4 : 3),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Inter',
                                  fontSize: 23,
                                  fontWeight: FontWeight.w400
                              ),
                              children: [
                                TextSpan(
                                    text: field.$2 == ValueType.temperature.name
                                        ? '°C\n'
                                        : field.$2 == ValueType.soilMoisture.name ||
                                        field.$2 == ValueType.humidity.name
                                        ? '%\n'
                                        : '?\n',
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.6),
                                        fontFamily: 'Inter',
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400
                                    )
                                ),

                              ]
                          ),
                        );
                      }
                  ),
                ),
                Positioned(
                  top: 25,
                  child: Text(
                      '${field.$2.substring(0,1).toUpperCase()}'
                          '${field.$2.substring(1,field.$2.length)}',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w400
                      )
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _chartScaffold(List<SensorNodeSnapshot> chartData, double snapOffset) {
    return Container(
      padding: const EdgeInsets.only(top: 50, right: 35),
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
            width: MediaQuery.of(context).size.width * 1.19,
            margin: const EdgeInsets.only(left: 39),
            child: AnimatedOpacity(
              opacity: _highLightedPointIndex != -1 ? 0.2 : 1,
              duration: const Duration(seconds: 1),
              curve: Curves.easeOutExpo,
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
                    ..._stackedLines(chartData)
                  ]
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<CartesianSeries> _stackedLines(List<SensorNodeSnapshot> chartData) {
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
                height: _highLightedPointIndex != -1 ? 4 : 6,
                width: _highLightedPointIndex != -1 ? 4 : 6
            ),
            dataLabelSettings: const DataLabelSettings(
                isVisible: false
            ),
            pointColorMapper: (SensorNodeSnapshot? data, point) {
              if (point != _highLightedPointIndex) {
                return _generateColor(field.name)!.withOpacity(0);
              }
              return null;
            },
            onPointDoubleTap: (point) {
              setState(() {
                _highLightedPointIndex = (point.pointIndex ?? (cData.length - 2)) + 1;
                _showRelativeTimeDisplay = false;
              });
              setState(() {
                _focusedPointSoilMoisture = cData[_highLightedPointIndex]!.soilMoisture;
                _focusedPointHumidity = cData[_highLightedPointIndex]!.humidity;
                _focusedPointTemperature = cData[_highLightedPointIndex]!.temperature;
              });
              _focusedPointTrigger();
            },
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

  Widget _onFocusChartScaffold(List<SensorNodeSnapshot> chartData) {
    return Container(
      padding: const EdgeInsets.only(top: 50, right: 35),
      height: 175,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        child: Container(
          width: MediaQuery.of(context).size.width * 1.19,
          margin: const EdgeInsets.only(left: 40),
          child: SfCartesianChart(
              plotAreaBorderWidth: 0.0,
              primaryXAxis: const CategoryAxis(
                isVisible: false,
                labelPlacement: LabelPlacement.onTicks,
              ),
              primaryYAxis: const NumericAxis(
                maximum: 100,
                minimum: 0,
                isVisible: false,
              ),
              series: <CartesianSeries>[
                ..._onFocusPointerDisplay(chartData)
              ]
          ),
        ),
      ),
    );
  }

  List<CartesianSeries> _onFocusPointerDisplay(List<SensorNodeSnapshot> chartData) {
    List<CartesianSeries> cartesianSeriesList = [];
    List<SensorNodeSnapshot?> cDataHidden = chartData.map((element) => element).toList();
    cDataHidden = List<SensorNodeSnapshot?>.generate(
        DatabaseHelper.maxChartLength - chartData.length, (index) => null) + cDataHidden;
    List<SensorNodeSnapshot?> cDataShow = List<SensorNodeSnapshot?>.generate(
      DatabaseHelper.maxChartLength, (index) => null
    );
    int indexOffset = (_calculatedOffset
        ~/ ((MediaQuery.of(context).size.width / 6) - 15.5)) - 1;
    if (_highLightedPointIndex != -1) {
      cDataShow.insert(
          _highLightedPointIndex - indexOffset,
          cDataHidden[_highLightedPointIndex]
      );
      cDataShow.removeAt(0);
    }
    for (ValueType field in ValueType.values.toList()) {
      int increment = 0;
      cartesianSeriesList.add(
        StackedLineSeries<SensorNodeSnapshot?, String>(
            markerSettings: MarkerSettings(
                color: _generateColor(field.name)!.withOpacity(
                    _highLightedPointIndex != -1 ? 0 : 1
                ),
                isVisible: true,
                height: 3,
                width: 3,
              borderWidth: 3
            ),
            animationDuration: _highLightedPointIndex != -1 ? 150 : 0,
            color: _generateColor(field.name),
            groupName: field.name,
            dataSource: cDataShow,
            xValueMapper: (SensorNodeSnapshot? data, _) {
              increment++;
              return _dateTimeFormatting.formatTimeClearZero(
                  DateTime.fromMillisecondsSinceEpoch(0).add(
                      Duration(hours: increment)
                  )
              );
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
      bottom: 75,
      right: 53 - 10.5,
      child: AnimatedOpacity(
        opacity: _showRelativeTimeDisplay ? 1 : 0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutExpo,
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

  Widget _staticTickLines() {
    List<SensorNodeSnapshot?> nullChart = List<SensorNodeSnapshot?>
        .generate(6, (index) => null);
    int increment = 0;
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: _highLightedPointIndex != -1
              ? [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.1)
                ]
              : [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(1)
                ],
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcIn, // Ensures the gradient fills the child.
      child: Container(
        padding: const EdgeInsets.only(top: 40, right: 35),
        height: 275,
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