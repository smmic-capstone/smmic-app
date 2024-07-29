import 'package:flutter/material.dart';
import 'package:smmic/models/device_data_models.dart';
import 'package:smmic/services/datetime_formatting.dart';
import 'package:smmic/services/devices/sensor_data.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class LineChart extends StatefulWidget {
  const LineChart({super.key, required this.deviceID});

  final String deviceID;

  @override
  State<LineChart> createState() => _LineChartState();
}

class _LineChartState extends State<LineChart> {

  final DatetimeFormatting _dateTimeFormatting = DatetimeFormatting();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.only(top: 15),
          height: 240,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _generateYAxisMarks(marks: [0, 25, 50, 75, 100], reversed: true),
          ),
        ),
        SizedBox(
          width: 285,
          child: SfCartesianChart(
              legend: Legend(
                  overflowMode: LegendItemOverflowMode.none,
                  isVisible: true,
                  iconHeight: 3,
                  iconWidth: 2.5
              ),
              primaryXAxis: CategoryAxis(
                labelStyle: TextStyle(fontSize: 10),
                tickPosition: TickPosition.inside,
                isVisible: true,
                labelPlacement: LabelPlacement.onTicks,
              ),
              primaryYAxis: NumericAxis(
                opposedPosition: false,
                majorGridLines: MajorGridLines(
                    color: Colors.transparent
                ),
                minimum: 0,
                maximum: 100,
                interval: 25,
                labelPosition: ChartDataLabelPosition.outside,
                isVisible: false,
              ),
              series: <CartesianSeries>[
                StackedLineSeries<SensorNodeSnapshot, String>(
                    markerSettings: MarkerSettings(
                        isVisible: true
                    ),
                    onPointTap: (data) {
                      //TODO: WTF??
                    },
                    legendItemText: 'Soil Moisture (%)',
                    groupName: 'Group A',
                    dataLabelSettings: DataLabelSettings(
                        useSeriesColor: true
                    ),
                    dataSource: SensorNodeDataServices().getTimeSeries(widget.deviceID),
                    xValueMapper: (SensorNodeSnapshot data, _) => _dateTimeFormatting.formatTimeClearZero(data.timestamp),
                    yValueMapper: (SensorNodeSnapshot data, _) => data.soilMoisture
                ),
                StackedLineSeries<SensorNodeSnapshot, String>(
                    legendItemText: 'Humidity',
                    groupName: 'Group B',
                    dataLabelSettings: DataLabelSettings(
                        useSeriesColor: true
                    ),
                    dataSource: SensorNodeDataServices().getTimeSeries(widget.deviceID),
                    xValueMapper: (SensorNodeSnapshot data, _) => _dateTimeFormatting.formatTimeClearZero(data.timestamp),
                    yValueMapper: (SensorNodeSnapshot data, _) => data.humidity
                ),
                //TODO: alignment still fucked
                StackedLineSeries<SensorNodeSnapshot, String>(
                    legendItemText: 'Temp',
                    groupName: 'Group C',
                    dataSource: SensorNodeDataServices().getTimeSeries(widget.deviceID),
                    xValueMapper: (SensorNodeSnapshot data, _) => _dateTimeFormatting.formatTimeClearZero(data.timestamp),
                    yValueMapper: (SensorNodeSnapshot data, _) => _scaleTemp(data.temperature.toInt())
                ),
              ]
          ),
        ),
        Container(
          padding: EdgeInsets.only(top: 15),
          height: 240,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _generateYAxisMarks(marks: [0, 10, 20, 40], reversed: true),
          ),
        )
      ],
    );
  }

  int _scaleTemp(int temp) {
    return temp;
  }

  List<Text> _generateYAxisMarks({required List<num> marks, required bool reversed}) {
    if(reversed) {
      return marks.reversed.map((mark) => Text(mark.toString(), style: TextStyle(fontSize: 10))).toList();
    }
    return marks.map((mark) => Text(mark.toString(), style: TextStyle(fontSize: 12))).toList();
  }
}

