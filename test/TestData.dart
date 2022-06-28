// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:goodlinker_chart/common/entry/ChartRuleLine.dart';
import 'package:goodlinker_chart/common/entry/TimestampXAxisData.dart';
import 'package:goodlinker_chart/common/entry/TimestampXAxisDataSet.dart';

class TestData {
  static const simulatedItemNumber = 240;
  static const simulatedDataInterval = 180;
  static const Size testCanvasSize = Size(108, 116);
  static const EdgeInsets testPadding = EdgeInsets.fromLTRB(4, 4, 4, 4);
  static const double xAxisHeightTest = 8;
  static final TimestampXAxisDataSet testDataSet = TimestampXAxisDataSet(
    data: [
      TimestampXAxisData(x: 500, y: 250),
      TimestampXAxisData(x: 540, y: 350),
      TimestampXAxisData(x: 580, y: 600),
      TimestampXAxisData(x: 620, y: 150),
      TimestampXAxisData(x: 660, y: 100),
      TimestampXAxisData(x: 700, y: 200),
    ],
    upperBaseline: ChartRuleline(dy: 400, baselineColor: Colors.red),
    lowerBaseline: ChartRuleline(dy: 350, baselineColor: Colors.red),
    xAxisStartPoint: 1655071200,
    xAxisEndPoint: 1655071200 + simulatedItemNumber * simulatedDataInterval,
  );
  static final TimestampXAxisDataSet expectDataSet = TimestampXAxisDataSet(
    data: [
      TimestampXAxisData(x: 4, y: 74),
      TimestampXAxisData(x: 24, y: 54),
      TimestampXAxisData(x: 44, y: 4),
      TimestampXAxisData(x: 64, y: 94),
      TimestampXAxisData(x: 84, y: 104),
      TimestampXAxisData(x: 104, y: 84),
    ],
    upperBaseline: ChartRuleline(dy: 44, baselineColor: Colors.red),
    lowerBaseline: ChartRuleline(dy: 54, baselineColor: Colors.red),
    xAxisStartPoint: 1655071200,
    xAxisEndPoint: 1655071200 + simulatedItemNumber * simulatedDataInterval,
  );
}
