import 'package:flutter/material.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';

class PieChart extends StatefulWidget {
  @override
  _PieChartState createState() => _PieChartState();
}

class _PieChartState extends State<PieChart> {

  final GlobalKey<AnimatedCircularChartState> _chartKey = new GlobalKey<AnimatedCircularChartState>();
  List<CircularStackEntry> data = <CircularStackEntry>[
    new CircularStackEntry(
      <CircularSegmentEntry>[
        new CircularSegmentEntry(42, Colors.red[400], rankKey: 'Unpublished'),
        new CircularSegmentEntry(38, Colors.green[400], rankKey: 'Published'),
        //new CircularSegmentEntry(2000.0, Colors.blue[200], rankKey: 'Q3'),
        //new CircularSegmentEntry(1000.0, Colors.yellow[200], rankKey: 'Q4'),
      ],
      rankKey: 'Published cars',
    ),
  ];

  Widget build(BuildContext context) {
    return new AnimatedCircularChart(
      key: _chartKey,
      size: const Size(100.0, 100.0),
      initialChartData: data,
      chartType: CircularChartType.Pie,
    );
  }

}


