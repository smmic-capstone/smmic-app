import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class LineChart extends StatefulWidget {
  const LineChart({super.key});

  @override
  State<LineChart> createState() => _LineChartState();
}

class _LineChartState extends State<LineChart> {
  @override
  Widget build(BuildContext context) {

    return Container(
      // child: SfCartesianChart(
      //     primaryXAxis: CategoryAxis(),
      //     series: <CartesianSeries>[
      //       StackedLineSeries<ChartData, String>(
      //           groupName: 'Group A'
      //           dataLabelSettings: DataLabelSettings(
      //               isVisible: true,
      //               useSeriesColor: true
      //           ),
      //           dataSource: chartData,
      //           xValueMapper: (ChartData data, _) => data.x,
      //           yValueMapper: (ChartData data, _) => data.y1
      //       ),
      //       StackedLineSeries<ChartData, String>(
      //           groupName: 'Group B',
      //           dataLabelSettings: DataLabelSettings(
      //               isVisible: true,
      //               useSeriesColor: true
      //           ),
      //           dataSource: chartData,
      //           xValueMapper: (ChartData data, _) => data.x,
      //           yValueMapper: (ChartData data, _) => data.y2
      //       ),
      //       StackedLineSeries<ChartData, String>(
      //           groupName: 'Group A',
      //           dataLabelSettings: DataLabelSettings(
      //               isVisible: true,
      //               useSeriesColor: true
      //           ),
      //           dataSource: chartData,
      //           xValueMapper: (ChartData data, _) => data.x,
      //           yValueMapper: (ChartData data, _) => data.y3
      //       ),
      //     ]
      // )
    );
  }
}

