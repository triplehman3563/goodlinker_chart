import 'package:flutter/material.dart';
import 'package:goodlinker_chart/src/entry/NewData.dart';
import 'package:goodlinker_chart/src/style/BarChartStyle.dart';
import 'package:goodlinker_chart/src/widget/BarPainter.dart';

class BarChart extends StatefulWidget {
  BarChart({
    Key? key,
    required this.dataSet,
  }) : super(key: key);
  final List<NewData> dataSet;

  @override
  State<BarChart> createState() => _BarChartState();
}

class _BarChartState extends State<BarChart> {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BarPainter(
        dataSet: widget.dataSet,
        barChartStyle: BarChartStyle(),
      ),
    );
  }
}
