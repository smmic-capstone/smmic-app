import 'dart:convert';
import 'dart:ui';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
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
    required this.deviceId,
    required this.currentDateTime
  });

  final DateTime currentDateTime;
  final String deviceId;

  @override
  State<StackedLineChart> createState() => _StackedLineChartState();
}

class _StackedLineChartState extends State<StackedLineChart> with TickerProviderStateMixin {
  // helpers, configs
  final DeviceUtils _deviceUtils = DeviceUtils();
  final DateTimeFormatting _dateTimeFormatting = DateTimeFormatting();

  // card variables
  double cardHeight = 300;

  // stacked line variables
  final ScrollController _stackedLinesScrollController = ScrollController();
  final ScrollController _onFocusPointScrollController = ScrollController();
  final ScrollController _followingTickLinesScrollController = ScrollController();
  bool _showRelativeTimeDisplay = false; //ignore: prefer_final_fields
  int _highLightedPointIndex = -1; // ignore: prefer_final_fields

  // focused value variables
  late AnimationController _valuesAnimationController;
  late CurvedAnimation _valuesAnimationCurve;
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
  late AnimationController _valueColoredLineAnimationController;
  late Animation _valueColoredLineAnimation;
  double _stackedLineScrollOffset = 0; // ignore: prefer_final_fields
  int _chartDataHash = -1; // ignore: prefer_final_fields

  // trigger focused point behavior
  void _focusedPointTrigger() {
    if (_highLightedPointIndex != -1) {
      setState(() {
        if (_valuesAnimationController.isCompleted) {
          _soilMoistureTween.begin = _soilMoistureTween.end;
          _humidityTween.begin = _humidityTween.end;
          _temperatureTween.begin = _temperatureTween.end;
          _valuesAnimationController.reset();
        } else {
          _valueColoredLineAnimationController.forward();
        }
        _soilMoistureTween.end = _focusedPointSoilMoisture;
        _temperatureTween.end = _focusedPointTemperature;
        _humidityTween.end = _focusedPointHumidity;
        _valuesAnimationController.forward();
      });
      return;
    } else {
      setState(() {
        _soilMoistureTween.begin = 0;
        _humidityTween.begin = 0;
        _temperatureTween.begin = 0;
        _valueColoredLineAnimationController.reset();
        _valuesAnimationController.reset();
      });
    }
  }

  late DevicesProvider _devicesProvider;
  void _updateWhileFocusedTrigger() {
    List<SensorNodeSnapshot>? chartList = _devicesProvider.sensorNodeChartDataMap[widget.deviceId];

    if (chartList == null || chartList.isEmpty) {
      return;
    }

    if (_chartDataHash == Object.hashAll(chartList)) {
      return;
    }

    setState(() {
      _chartDataHash = Object.hashAll(chartList);
    });

    if (_highLightedPointIndex != -1) {
      setState(() {
        _focusedPointSoilMoisture = chartList[_highLightedPointIndex].soilMoisture;
        _focusedPointTemperature = chartList[_highLightedPointIndex].temperature;
        _focusedPointHumidity = chartList[_highLightedPointIndex].humidity;
        _focusedPointTrigger();
      });
      return;
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

  void _syncScrollOffsets() {
    _followingTickLinesScrollController.jumpTo(_stackedLinesScrollController.offset);
  }

  // snaps the stacked line chart points to match background tick lines
  void _stackedLineSnapToOffset(double snapOffset) {
    double currentOffset = _stackedLinesScrollController.offset;
    double calculatedSnapPoint = (currentOffset / snapOffset).round() * snapOffset;
    double maxScrollExtent = _stackedLinesScrollController.position.maxScrollExtent;
    double finalSnapPoint = calculatedSnapPoint;
    if (currentOffset != maxScrollExtent) {
      if (calculatedSnapPoint > maxScrollExtent) {
        finalSnapPoint = _stackedLinesScrollController.position.maxScrollExtent;
        _stackedLinesScrollController.animateTo(
            finalSnapPoint,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutExpo
        );
      } else {
        _stackedLinesScrollController.animateTo(
            finalSnapPoint,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutExpo
        );
      }
    }
    setState(() {
      _stackedLineScrollOffset = finalSnapPoint;
    });
    _onFocusPointScrollController.jumpTo(finalSnapPoint);
  }

  // generate a color for fields
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

    _valueColoredLineAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(
          milliseconds: 500
      ),
    );
    // underline field indicator animation
    _valueColoredLineAnimation = Tween<double>(begin: 0,end: 25).animate(
        CurvedAnimation(
            parent: _valueColoredLineAnimationController,
            curve: Curves.easeInOutExpo
        )
    );

    // values animation variables
    _valuesAnimationCurve = CurvedAnimation(
        parent: _valuesAnimationController,
        curve: Curves.easeInOutExpo
    );
    _soilMoistureAnimation = _soilMoistureTween.animate(_valuesAnimationCurve);
    _temperatureAnimation = _temperatureTween.animate(_valuesAnimationCurve);
    _humidityAnimation = _humidityTween.animate(_valuesAnimationCurve);

    // set to list to access by index
    _valuesAnimationList = [
      _soilMoistureAnimation,
      _temperatureAnimation,
      _humidityAnimation
    ];

    // init to end of list
    WidgetsBinding.instance.addPostFrameCallback((_) {
      double maxScrollExtent = _stackedLinesScrollController.position.maxScrollExtent;
      setState(() {
        _stackedLineScrollOffset = maxScrollExtent;
      });
      _stackedLinesScrollController.jumpTo(
          maxScrollExtent
      );
      _onFocusPointScrollController.jumpTo(
          maxScrollExtent
      );
      _devicesProvider = context.read<DevicesProvider>();
      context.read<DevicesProvider>().addListener(_updateWhileFocusedTrigger);
    });
    _stackedLinesScrollController.addListener(_relativeToNowOpacityTrigger);
    _stackedLinesScrollController.addListener(_syncScrollOffsets);

    super.initState();
  }

  @override
  void dispose() {
    _onFocusPointScrollController.dispose();
    _stackedLinesScrollController.removeListener(_relativeToNowOpacityTrigger);
    _stackedLinesScrollController.removeListener(_syncScrollOffsets);
    _devicesProvider.removeListener(_updateWhileFocusedTrigger);
    _stackedLinesScrollController.dispose();
    _valuesAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // calculated snap offset
    final double screenSize = MediaQuery.of(context).size.width;
    final double screenSizeOffset = screenSize - (screenSize * 0.9999);
    final double stackedLineSnapOffset = ((screenSize) / (8 - screenSizeOffset)).roundToDouble();
    // chart data from devices provider
    List<SensorNodeSnapshot> chartData = context.watch<DevicesProvider>()
        .sensorNodeChartDataMap[widget.deviceId] ?? [];

    setState(() {
      _chartDataHash = Object.hashAll(chartData);
    });

    return Listener(
      onPointerUp: (_) {
        setState(() {
          _highLightedPointIndex = -1;
          double max = _stackedLinesScrollController.position.maxScrollExtent;
          double current = _stackedLinesScrollController.offset;
          double threshold = 15;
          _showRelativeTimeDisplay = (max - current) < threshold;
        });
        _focusedPointTrigger();
      },
      child: Stack(
        children: [
          _renderBackground(),
          //_staticTickLines(),
          Container(
            margin: const EdgeInsets.only(top: 25),
            child: _followingTickLines(chartData.length),
          ),
          Container(
            margin: const EdgeInsets.only(top: 25),
            child: _onFocusChartBase(chartData),
          ),
          Container(
            margin: const EdgeInsets.only(top: 25),
            child: _chartBase(chartData, stackedLineSnapOffset),
          ),
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
          Builder(
            builder: (context) {
              int indexOffset = DatabaseHelper.maxChartLength - chartData.length;
              int finalIndex = _highLightedPointIndex - indexOffset;
              double opacity = 0;
              if (_highLightedPointIndex != -1) {
                opacity = 1;
                return _focusedPointRelativeToNowDisplay(
                  chartData[finalIndex].timestamp,
                  opacity,
                  stackedLineSnapOffset
                );
              } else {
                return const SizedBox();
              }
            },
          ),
          chartData.isEmpty
              ? const SizedBox()
              : _relativeToNowDisplay(chartData.last.timestamp),
        ],
      ),
    );
  }

  Widget _renderBackground() {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(25)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AnimatedOpacity(
          opacity: _highLightedPointIndex != -1
              ? 0.8
              : 0.65,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutExpo,
          child: Container(
            color: Colors.black,
            height: 300,
          ),
        ),
      ),
    );
  }

  Widget _staticTickLines() {
    // gradient settings
    List<Color> pointsFocused = [
      Colors.white.withOpacity(0.1),
      Colors.white.withOpacity(0.1)
    ];
    List<Color> defaultGradient = [
      Colors.white.withOpacity(0.1),
      Colors.white.withOpacity(0.2),
      Colors.white.withOpacity(1)
    ];
    LinearGradient gradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: _highLightedPointIndex != -1
          ? pointsFocused
          : defaultGradient,
    );

    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return gradient.createShader(bounds);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 35),
        alignment: Alignment.center,
        height: cardHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ...List.generate(6, (i) => i).map((index) {
              return Container(
                width: 1,
                color: Colors.white,
              );
            })
          ],
        ),
      ),
    );
  }

  Widget _followingTickLines(int charDataLength) {
    List<SensorNodeSnapshot?> nullChartList = List<SensorNodeSnapshot?>
        .generate(10, (index) => null);

    int dummyTimeHourIncrement = 0;
    SfCartesianChart cartesianChart = SfCartesianChart(
        plotAreaBorderWidth: 0.0,
        primaryXAxis: const CategoryAxis(
          rangePadding: ChartRangePadding.none,
          axisLine: AxisLine(
              color: Colors.transparent
          ),
          labelStyle: TextStyle(
              fontSize: 0,
              color: Colors.transparent
          ),
          tickPosition: TickPosition.inside,
          isVisible: true,
          labelPlacement: LabelPlacement.onTicks,
        ),
        primaryYAxis: const NumericAxis(
          maximum: 100,
          minimum: 0,
          isVisible: false,
        ),
        series: <CartesianSeries>[
          StackedLineSeries<SensorNodeSnapshot?, String>(
              dataSource: nullChartList,
              xValueMapper: (SensorNodeSnapshot? data, _) {
                dummyTimeHourIncrement++;
                return _dateTimeFormatting.formatTimeClearZero(
                    DateTime.fromMillisecondsSinceEpoch(0).add(
                        Duration(
                            hours: dummyTimeHourIncrement
                        )
                    )
                );
              },
              yValueMapper: (SensorNodeSnapshot? data, _) {
                return null;
              }
          )
        ]
    );

    double screenWidth = MediaQuery.of(context).size.width;

    // gradient settings
    List<Color> pointsFocused = [
      Colors.white.withOpacity(0.1),
      Colors.white.withOpacity(0.1)
    ];
    List<Color> defaultGradient = [
      Colors.white.withOpacity(0.1),
      Colors.white.withOpacity(0.5),
      Colors.white.withOpacity(1)
    ];
    LinearGradient gradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: _highLightedPointIndex != -1
          ? pointsFocused
          : defaultGradient,
    );

    return SizedBox(
      height: 250,
      child: SingleChildScrollView(
        controller: _followingTickLinesScrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: screenWidth - (screenWidth * 0.91)),
          width: ((screenWidth - 70) / 6) * 10,
          height: 250,
          child: ShaderMask(
            shaderCallback: (Rect bounds) {
              return gradient.createShader(bounds);
            },
            child: cartesianChart,
          ),
        ),
      ),
    );
  }

  Widget _legends() {
    // legend fields
    List<String> legends = [
      'Soil Moisture',
      'Temperature',
      'Humidity'
    ];
    double circleSize = 6.0;

    List<Widget> legendTitles = legends.map((legend) {
      // the colored circle indicator for each field
      Widget coloredCircle = Container(
        width: circleSize,
        height: circleSize,
        decoration: BoxDecoration(
            color: _generateColor(
                legend.toLowerCase()
            )!.withOpacity(0.5),
            borderRadius: const BorderRadius.all(
                Radius.circular(50)
            )
        ),
      );
      // title of the legend
      Widget text = Text(
        legend,
        style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w400
        ),
      );
      return SizedBox(
        height: 20,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            coloredCircle,
            const SizedBox(width: 5),
            text
          ],
        ),
      );
    }).toList();

    return Positioned(
      bottom: 60,
      left: 45,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...legendTitles
        ],
      ),
    );
  }

  Widget _focusedPointValues(SensorNodeSnapshot focusedData) {
    // field value titles
    List<String> values = [
      'soil moisture',
      'temperature',
      'humidity'
    ];

    // field value widget variables
    double fieldValueHeight = 50;
    double fieldValueWidth = 85;
    TextStyle valueTextStyle = const TextStyle(
        color: Colors.white,
        fontFamily: 'Inter',
        fontSize: 23,
        fontWeight: FontWeight.w500
    );
    TextStyle symbolTextStyle = const TextStyle(
        color: Colors.white,
        fontFamily: 'Inter',
        fontSize: 15,
        fontWeight: FontWeight.w400
    );
    TextStyle titleTextStyle = TextStyle(
        color: Colors.white.withOpacity(0.5),
        fontFamily: 'Inter',
        fontSize: 12,
        fontWeight: FontWeight.w400
    );
    
    Widget buildColoredUnderline(String fieldTitle) {
      return Positioned(
        left: 0,
        bottom: 3,
        child: AnimatedBuilder(
            animation: _valueColoredLineAnimation,
            builder: (context, child) {
              return Container(
                width: _valueColoredLineAnimation.value,
                height: 2,
                decoration: BoxDecoration(
                    color: _generateColor(fieldTitle),
                    borderRadius: const BorderRadius.all(
                        Radius.circular(25)
                    )
                ),
              );
            }
        ),
      );
    }

    Widget buildFieldValue((int, String) fieldVars) {
      TextSpan fieldSymbol = TextSpan(
          text: fieldVars.$2 == ValueType.temperature.name
              ? '°C\n'
              : fieldVars.$2 == ValueType.soilMoisture.name ||
              fieldVars.$2 == ValueType.humidity.name
              ? '%\n'
              : '?\n',
          style: symbolTextStyle
      );

      return Container(
        margin: const EdgeInsets.only(right: 10),
        height: fieldValueHeight,
        width: fieldValueWidth,
        child: AnimatedBuilder(
            animation: _valuesAnimationList[fieldVars.$1],
            builder: (context, child) {
              String value = _valuesAnimationList[fieldVars.$1].value.toString();
              String finalValue = value.substring(0, value.length > 3 ? 4 : 3);
              return RichText(
                text: TextSpan(
                    text: finalValue,
                    style: valueTextStyle,
                    children: [fieldSymbol]
                ),
              );
            }
        ),
      );
    }

    Widget buildFieldTitle(String title) {
      return Text(
          '${title.substring(0,1).toUpperCase()}'
              '${title.substring(1, title.length)}',
          style: titleTextStyle
      );
    }

    Widget stackWrapper((int, String) fieldVars) {
      return Stack(
        children: [
          buildColoredUnderline(fieldVars.$2),
          buildFieldValue(fieldVars),
          Positioned(
            top: 25,
            child: buildFieldTitle(fieldVars.$2),
          ),
        ],
      );
    }
    
    return Positioned(
      bottom: 65,
      left: 45,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...values.indexed.map((field) => stackWrapper(field))
        ],
      ),
    );
  }

  Widget _focusedPointRelativeToNowDisplay(DateTime timestamp, double opacity, double snapOffset) {

    // get the display index of the focused points relative to the view
    double currentViewIndexStart = _stackedLineScrollOffset / snapOffset;
    int displayIndexRelativeToView = ((currentViewIndexStart - _highLightedPointIndex) * -1).toInt();

    // text styles
    TextStyle primaryTextStyle = const TextStyle(
        color: Colors.white,
        fontFamily: 'Inter',
        fontSize: 23,
        fontWeight: FontWeight.w500
    );
    TextStyle secondaryTextStyle = const TextStyle(
      color: Colors.white,
      fontFamily: 'Inter',
      fontSize: 15,
      fontWeight: FontWeight.w400
    );
    TextStyle tertiaryTextStyle = TextStyle(
        color: Colors.white.withOpacity(0.75),
        fontFamily: 'Inter',
        fontSize: 12,
        fontWeight: FontWeight.w400
    );

    return Positioned(
      top: 70,
      left: displayIndexRelativeToView >= 3 ? 45 : null,
      right: displayIndexRelativeToView <= 2 ? 55 : null,
      child: Container(
        alignment: displayIndexRelativeToView >= 3
            ? Alignment.centerLeft
            : Alignment.centerRight,
        height: 70,
        width: 150,
        child: StreamBuilder(
            stream: _deviceUtils.timeTickerSeconds(),
            builder: (context, snapshot) {
              String finalText = _deviceUtils.relativeTimeDisplay(
                timestamp,
                snapshot.data ?? DateTime.now(),
              );
              return RichText(
                textAlign: displayIndexRelativeToView >= 3
                    ? TextAlign.start
                    : TextAlign.end,
                text: TextSpan(
                  text: finalText.split(' ').first,
                  style: primaryTextStyle,
                  children: [
                    TextSpan(
                      text: ' ${finalText.split(' ')[1]} '
                          '${finalText.split(' ')[2]}',
                      style: secondaryTextStyle
                    ),
                    TextSpan(
                        text: '\n\n${DateFormat("h:mm a\nMMMM d").format(timestamp)}',
                        style: tertiaryTextStyle
                    ),
                  ]
                ),
              );
            }
        ),
      ),
    );
  }

  // chart variables
  double chartWidth = 500;
  double chartHeight = 175;

  Widget _chartBase(List<SensorNodeSnapshot> chartData, double snapOffset) {
    // widget variables
    ScrollPhysics scrollPhysics = chartData.length < 6
        ? const NeverScrollableScrollPhysics()
        : const AlwaysScrollableScrollPhysics();

    // the actual chart base
    SfCartesianChart cartesianChart = SfCartesianChart(
        plotAreaBorderWidth: 0.0,
        primaryXAxis: const CategoryAxis(
          rangePadding: ChartRangePadding.none,
          axisLine: AxisLine(
              color: Colors.transparent
          ),
          labelStyle: TextStyle(
              fontSize: 0,
              color: Colors.transparent
          ),
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
          ..._buildStackedLines(chartData)
        ]
    );

    double screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      height: chartHeight,
      child: Listener(
        onPointerUp: (_) => _stackedLineSnapToOffset(snapOffset),
        child: SingleChildScrollView(
          physics: scrollPhysics,
          controller: _stackedLinesScrollController,
          scrollDirection: Axis.horizontal,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: screenWidth - (screenWidth * 0.91)),
            width: ((screenWidth - 70) / 6) * 10,
            child: AnimatedOpacity(
              opacity: _highLightedPointIndex != -1 ? 0.15 : 1,
              duration: const Duration(seconds: 1),
              curve: Curves.easeOutExpo,
              child: cartesianChart,
            ),
          ),
        ),
      ),
    );
  }

  List<CartesianSeries> _buildStackedLines(List<SensorNodeSnapshot> chartData) {
    List<CartesianSeries> cartesianSeriesList = [];

    // pad chart with null values if actual chart data is less that
    // the max chart length
    List<SensorNodeSnapshot?> paddedChart = List<SensorNodeSnapshot?>.generate(
        DatabaseHelper.maxChartLength - chartData.length, (index) => null) + chartData;

    // stacked line variables
    MarkerSettings buildMarker(String fieldName) {
      return MarkerSettings(
          color: _generateColor(fieldName),
          isVisible: true,
          height: _highLightedPointIndex != -1 ? 4 : 6,
          width: _highLightedPointIndex != -1 ? 4 : 6
      );
    }
    DataLabelSettings labelSettings = const DataLabelSettings(
      isVisible: false
    );
    double animationDuration = 500;
    
    // mappers, wrapper functions
    Color? pointColorGenerator(int point, String fieldName) {
      if (point != _highLightedPointIndex) {
        return _generateColor(fieldName)!.withOpacity(0);
      }
      return null;
    }

    void doubleTapTrigger(ChartPointDetails point) {
      int pointIndex = point.pointIndex ?? paddedChart.length - 2;
      setState(() {
        _highLightedPointIndex = pointIndex + 1;
        _showRelativeTimeDisplay = false;
      });
      setState(() {
        _focusedPointSoilMoisture = paddedChart[_highLightedPointIndex]!.soilMoisture;
        _focusedPointHumidity = paddedChart[_highLightedPointIndex]!.humidity;
        _focusedPointTemperature = paddedChart[_highLightedPointIndex]!.temperature;
      });
      _focusedPointTrigger();
    }

    String? timeAxisGenerator(SensorNodeSnapshot? data, int falseHourIncrement) {
      if (data != null) {
        return _dateTimeFormatting.formatTimeClearZero(data.timestamp);
      } else {
        return _dateTimeFormatting.formatTimeClearZero(
            DateTime.fromMillisecondsSinceEpoch(0).add(
                Duration(hours: falseHourIncrement)
            )
        );
      }
    }
    num? numericAxisGenerator(SensorNodeSnapshot? data, String fieldName) {
      if (data != null) {
        if (fieldName == ValueType.soilMoisture.name) {
          return data.soilMoisture;
        } else if (fieldName == ValueType.temperature.name) {
          return _scaleTemp(data.temperature.toInt());
        } else if (fieldName == ValueType.humidity.name) {
          return data.humidity;
        }
      }
      return null;
    }
    
    for (ValueType field in ValueType.values.toList()) {
      int increment = 0;
      cartesianSeriesList.add(
        StackedLineSeries<SensorNodeSnapshot?, String>(
            markerSettings: buildMarker(field.name),
            dataLabelSettings: labelSettings,
            pointColorMapper: (SensorNodeSnapshot? data, point) {
              return pointColorGenerator(
                  point,
                  field.name
              );
            },
            onPointLongPress: (ChartPointDetails point) {
              doubleTapTrigger(point);
            },
            onPointDoubleTap: (ChartPointDetails point) {
              doubleTapTrigger(point);
            },
            animationDuration: animationDuration,
            color: _generateColor(field.name),
            groupName: field.name,
            dataSource: paddedChart,
            xValueMapper: (SensorNodeSnapshot? data, _) {
              increment++;
              return timeAxisGenerator(data, increment);
            },
            yValueMapper: (SensorNodeSnapshot? data, _) {
              return numericAxisGenerator(data, field.name);
            }
        ),
      );
    }
    
    return cartesianSeriesList;
  }

  Widget _onFocusChartBase(List<SensorNodeSnapshot> chartData) {
    SfCartesianChart cartesianChart = SfCartesianChart(
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
    );

    double screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      height: chartHeight,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _onFocusPointScrollController,
        scrollDirection: Axis.horizontal,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: screenWidth - (screenWidth * 0.91)),
          width: ((screenWidth - 70) / 6) * 10,
          height: chartHeight,
          child: cartesianChart,
        ),
      ),
    );
  }

  List<CartesianSeries> _onFocusPointerDisplay(List<SensorNodeSnapshot> chartData) {
    List<CartesianSeries> cartesianSeriesList = [];

    // pad chart data with null values if less than max chart length
    List<SensorNodeSnapshot?> paddedChartData = chartData.map((element) => element).toList();
    paddedChartData = List<SensorNodeSnapshot?>.generate(
        DatabaseHelper.maxChartLength - chartData.length, (index) => null) + paddedChartData;

    // the chart data that is actually used by the stacked line series,
    // filled with null values
    List<SensorNodeSnapshot?> displayedChartData = List<SensorNodeSnapshot?>.generate(
      10, (index) => null
    );

    if (_highLightedPointIndex != -1) {
      displayedChartData.insert(
          _highLightedPointIndex + 1,
          paddedChartData[_highLightedPointIndex]
      );
      displayedChartData.removeAt(0);
    }

    // stacked line variables
    MarkerSettings buildMarker(String fieldName) {
      return MarkerSettings(
          color: _generateColor(fieldName)!.withOpacity(
              _highLightedPointIndex != -1 ? 0 : 1
          ),
          isVisible: true,
          height: 3,
          width: 3,
          borderWidth: 3
      );
    }

    // generator functions
    String timeAxisGenerator(int falseHourIncrement) {
      return _dateTimeFormatting.formatTimeClearZero(
          DateTime.fromMillisecondsSinceEpoch(0).add(
              Duration(hours: falseHourIncrement)
          )
      );
    }

    num? numericAxisGenerator(SensorNodeSnapshot? data, String fieldName) {
      if (data != null) {
        if (fieldName == ValueType.soilMoisture.name) {
          return data.soilMoisture;
        } else if (fieldName == ValueType.temperature.name) {
          return _scaleTemp(data.temperature.toInt());
        } else if (fieldName == ValueType.humidity.name) {
          return data.humidity;
        }
      }
      return null;
    }
    
    for (ValueType field in ValueType.values.toList()) {
      int increment = 0;
      cartesianSeriesList.add(
        StackedLineSeries<SensorNodeSnapshot?, String>(
            markerSettings: buildMarker(field.name),
            animationDuration: _highLightedPointIndex != -1 ? 150 : 0,
            color: _generateColor(field.name),
            groupName: field.name,
            dataSource: displayedChartData,
            xValueMapper: (SensorNodeSnapshot? data, _) {
              increment++;
              return timeAxisGenerator(increment);
            },
            yValueMapper: (SensorNodeSnapshot? data, _) {
              return numericAxisGenerator(data, field.name);
            }
        ),
      );
    }

    return cartesianSeriesList;
  }

  Widget _relativeToNowDisplay(DateTime lastReadingTimestamp) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Positioned(
      bottom: 75,
      right: screenWidth - (screenWidth * 0.894),
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
              child: Builder(
                  builder: (context) {
                    return Text(
                      _deviceUtils.relativeTimeDisplay(
                          lastReadingTimestamp,
                          widget.currentDateTime
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
}