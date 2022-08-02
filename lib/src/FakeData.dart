// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:goodlinker_chart/src/entry/ChartRuleLine.dart';
import 'package:goodlinker_chart/src/entry/TimestampXAxisData.dart';
import 'package:goodlinker_chart/src/entry/TimestampXAxisDataSet.dart';

class FakeData {
  static List<List<double>> fakeDataSets = [
    [410, 410, 410],
    [400, 400, 400],
    [390, 390, 390],
    [360, 360, 360],
    [350, 350, 350],
    [340, 340, 340],
    [410, 400, 410],
    [390, 400, 390],
    [410, 420, 430, 420, 500, 630, 520, 480],
    [410, 380, 340, 350, 365, 385, 475, 532, 474, 323, 253, 289, 330],
    [360, 350, 340],
    [340, 350, 340],
  ];

  static List<double> bigFakeData = [
    410,
    420,
    430,
    420,
    500,
    630,
    520,
    480,
    400,
    400,
    400,
    410,
    380,
    340,
    350,
    365,
    385,
    475,
    350,
    350,
    350,
    532,
    474,
    323,
    253,
    289,
    340,
    350,
    340,
    475,
    532,
    474,
    323,
    330,
    475,
    532,
    474,
    323,
    340,
    340,
    340,
  ];
  static final simulatedItemNumber = 240;
  static final simulatedDataInterval = 180;
  static var fakeTimestampXAxisDataSet = TimestampXAxisDataSet(
    data: Iterable.generate(simulatedItemNumber, (index) {
      final List<double> fakeData = FakeData.bigFakeData;
      return TimestampXAxisData(
          x: 1655071200 + index * simulatedDataInterval,
          y: fakeData[index % fakeData.length]);
    }).toList(),
    xAxisStartPoint: 1655071200,
    xAxisEndPoint: 1655071200 + simulatedItemNumber * simulatedDataInterval,
    // baseline: [350, 400],
    upperBaseline: const ChartBaseline(dy: 400, baselineColor: Colors.red),
    lowerBaseline: const ChartBaseline(dy: 350, baselineColor: Colors.red),
  );
}
