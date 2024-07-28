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
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 25),
      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
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
      height: 300,
      child: SfCartesianChart(
        legend: Legend(
          overflowMode: LegendItemOverflowMode.none,
          isVisible: true,
          iconHeight: 3,
          iconWidth: 2.5
        ),
        plotAreaBorderWidth: 1,
          primaryXAxis: CategoryAxis(
            tickPosition: TickPosition.inside,
            isVisible: true,
            labelPlacement: LabelPlacement.onTicks,
          ),
          series: <CartesianSeries>[
            StackedLineSeries<SensorNodeSnapshot, String>(
              markerSettings: MarkerSettings(
                isVisible: true
              ),
              onPointTap: (data) {
                //TODO: WTF??
                print(data.dataPoints![data.viewportPointIndex!.toInt()]);
              },
              legendItemText: 'Soil Moisture',
                groupName: 'Group A',
                dataLabelSettings: DataLabelSettings(
                    useSeriesColor: true
                ),
                dataSource: SensorNodeDataServices().getTimeSeries(widget.deviceID),
                xValueMapper: (SensorNodeSnapshot data, _) => _dateTimeFormatting.formatTime(data.timestamp),
                yValueMapper: (SensorNodeSnapshot data, _) => data.soilMoisture
            ),
            StackedLineSeries<SensorNodeSnapshot, String>(
              legendItemText: 'Humidity',
                groupName: 'Group B',
                dataLabelSettings: DataLabelSettings(
                    useSeriesColor: true
                ),
                dataSource: SensorNodeDataServices().getTimeSeries(widget.deviceID),
                xValueMapper: (SensorNodeSnapshot data, _) => _dateTimeFormatting.formatTime(data.timestamp),
                yValueMapper: (SensorNodeSnapshot data, _) => data.humidity
            ),
            StackedLineSeries<SensorNodeSnapshot, String>(
              legendItemText: 'Temp',
                groupName: 'Group C',
                dataLabelSettings: DataLabelSettings(
                    useSeriesColor: true
                ),
                dataSource: SensorNodeDataServices().getTimeSeries(widget.deviceID),
                xValueMapper: (SensorNodeSnapshot data, _) => _dateTimeFormatting.formatTime(data.timestamp),
                yValueMapper: (SensorNodeSnapshot data, _) => data.temperature
            ),
          ]
      )
    );
  }
}

