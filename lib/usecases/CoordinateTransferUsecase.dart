// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:goodlinker_chart/Utils.dart';
import 'package:goodlinker_chart/common/entry/ChartRuleLine.dart';
import 'package:goodlinker_chart/common/entry/TimestampXAxisData.dart';
import 'package:goodlinker_chart/common/entry/TimestampXAxisDataSet.dart';

class CoordinateTransferUsecase {
  TimestampXAxisDataSet transferToCanvasCoor({
    required TimestampXAxisDataSet dataSet,
    required Size canvasSize,
    required EdgeInsets padding,
  }) {
    final offsets =
        dataSet.data.map((e) => Offset(e.x.toDouble(), e.y)).toList();
    final upperBaseline = dataSet.upperBaseline;
    final lowerBaseline = dataSet.lowerBaseline;
    var yDataSets = offsets.map((e) => e.dy).toList();
    if (upperBaseline != null) {
      yDataSets.add(upperBaseline.dy);
    }
    if (lowerBaseline != null) {
      yDataSets.add(lowerBaseline.dy);
    }

    final xMax = offsets.map((e) => e.dx).toList().max();
    final xMin = offsets.map((e) => e.dx).toList().min();
    final xRange = xMax - xMin;
    final yMax = yDataSets.max();
    final yMin = yDataSets.min();
    final yRange = yMax - yMin;
    final xRatio = xRange == 0 ? 1.0 : canvasSize.width / xRange;
    final yRatio = yRange == 0 ? 1.0 : canvasSize.height / yRange;
    return TimestampXAxisDataSet(
      data: offsets.map((e) {
        final result = e
            .translate(-xMin, -yMin)
            .scale(xRatio, -yRatio)
            .translate(padding.left, canvasSize.height + padding.top);
        return TimestampXAxisData(x: result.dx.toInt(), y: result.dy);
      }).toList(),
      xAxisStartPoint: dataSet.xAxisStartPoint,
      xAxisEndPoint: dataSet.xAxisEndPoint,
      upperBaseline: upperBaseline != null
          ? ChartRuleline(
              dy: canvasSize.height +
                  padding.top +
                  (upperBaseline.dy - yMin) * -yRatio,
              baselineColor: dataSet.upperBaseline?.baselineColor)
          : null,
      lowerBaseline: lowerBaseline != null
          ? ChartRuleline(
              dy: canvasSize.height +
                  padding.top +
                  (lowerBaseline.dy - yMin) * -yRatio,
              baselineColor: dataSet.lowerBaseline?.baselineColor)
          : null,
    );
  }
}
