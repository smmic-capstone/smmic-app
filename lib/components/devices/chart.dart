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

  final List<Map<String, dynamic>> data = [
    {'name': 'soil moisture', 'legendTitle' : 'Soil Moisture (%)', 'type' : 'percentage',},
    {'name': 'humidity', 'legendTitle' : 'Humidity (%)', 'type' : 'percentage',},
    {'name': 'temperature', 'legendTitle' : 'Temp (°C)', 'type' : 'celcius',}
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 275,
          height: 25,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ...data.map((item) => _buildLegendItems(item['name'], item['legendTitle']))
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 225,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _buildYAxisLabels(marks: [0, 25, 50, 75, 100], reversed: true, type: 'percentage'),
              ),
            ),
            SizedBox(
              width: 270,
              height: 230,
              child: SfCartesianChart(
                  primaryXAxis: const CategoryAxis(
                    axisLine: AxisLine(
                        color: Colors.transparent
                    ),
                    labelStyle: TextStyle(fontSize: 0, color: Colors.transparent),
                    tickPosition: TickPosition.inside,
                    isVisible: true,
                    labelPlacement: LabelPlacement.onTicks,
                  ),
                  primaryYAxis: const NumericAxis(
                    isVisible: false,
                  ),
                  series: <CartesianSeries>[
                    StackedLineSeries<SensorNodeSnapshot, String>(
                      color: _generateColor('soil moisture'),
                        groupName: 'Group A',
                        dataSource: SensorNodeDataServices().getTimeSeries(widget.deviceID),
                        xValueMapper: (SensorNodeSnapshot data, _) => _dateTimeFormatting.formatTimeClearZero(data.timestamp),
                        yValueMapper: (SensorNodeSnapshot data, _) => data.soilMoisture
                    ),
                    StackedLineSeries<SensorNodeSnapshot, String>(
                      color: _generateColor('humidity'),
                        groupName: 'Group B',
                        dataSource: SensorNodeDataServices().getTimeSeries(widget.deviceID),
                        xValueMapper: (SensorNodeSnapshot data, _) => _dateTimeFormatting.formatTimeClearZero(data.timestamp),
                        yValueMapper: (SensorNodeSnapshot data, _) => data.humidity
                    ),
                    StackedLineSeries<SensorNodeSnapshot, String>(
                      color: _generateColor('temperature'),
                        groupName: 'Group C',
                        dataSource: SensorNodeDataServices().getTimeSeries(widget.deviceID),
                        xValueMapper: (SensorNodeSnapshot data, _) => _dateTimeFormatting.formatTimeClearZero(data.timestamp),
                        yValueMapper: (SensorNodeSnapshot data, _) => _scaleTemp(data.temperature.toInt())
                    ),
                  ]
              ),
            ),
            SizedBox(
              height: 225,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _buildYAxisLabels(marks: [15, 20, 25, 30, 35], reversed: true, type: 'celcius'),
              ),
            )
          ],
        ),
        SizedBox(
          height: 25,
          width: 325,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ..._buildXAxisLabels(marks: SensorNodeDataServices().getTimeSeries(widget.deviceID).map((snapshot){
                return _dateTimeFormatting.formatTimeClearZero(snapshot.timestamp);
              }).toList())
            ],
          ),
        )
      ],
    );
  }

  int _scaleTemp(int temp) {
    //TODO: format this variable so it aligns with the chart
    return temp;
  }

  Widget _buildLegendItems(String name, String title) {
    return Row(
      children: [
        Icon(Icons.circle, color: _generateColor(name), size: 6),
        const SizedBox(width: 3),
        Text(title, style: const TextStyle(fontSize: 11))
      ],
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

  List<Text> _buildXAxisLabels({required List<String> marks}){
    TextStyle style = const TextStyle(fontSize: 10);
    return marks.map((mark) => Text(mark, style: style)).toList();
  }

  List<Text> _buildYAxisLabels({required List<num> marks, required bool reversed, required String type}) {
    TextStyle style = const TextStyle(fontSize: 10, color: Colors.black45);
    List<Text> yAxisMarks = marks.map((mark){
      if (type == 'percentage'){
        return  Text('${mark.toString()}%', style: style);
      }
      if (type == 'celcius'){
        return  Text('${mark.toString()}°C', style: style);
      }
      return Text('unkown type: $type! use either `percentage` or `celcius`.');
    }).toList();
    if(reversed) {
      return yAxisMarks.reversed.toList();
    }
    return yAxisMarks;
  }
}

