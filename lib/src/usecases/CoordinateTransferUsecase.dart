// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:goodlinker_chart/src/Utils.dart';
import 'package:goodlinker_chart/src/entry/ChartRuleLine.dart';
import 'package:goodlinker_chart/src/entry/TimestampXAxisData.dart';
import 'package:goodlinker_chart/src/entry/TimestampXAxisDataSet.dart';

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

    final xRange = dataSet.xAxisEndPoint - dataSet.xAxisStartPoint;
    final yMax = yDataSets.max();
    final yMin = yDataSets.min();
    final yRange = yMax - yMin;
    final xRatio = xRange == 0 ? 1.0 : canvasSize.width / xRange;
    final yRatio = yRange == 0 ? 1.0 : canvasSize.height / yRange;
    return TimestampXAxisDataSet(
      data: offsets.map((e) {
        final result = e
            .translate(-dataSet.xAxisStartPoint.toDouble(), -yMin)
            .scale(xRatio, -yRatio)
            .translate(padding.left, canvasSize.height + padding.top);
        return TimestampXAxisData(x: result.dx.toInt(), y: result.dy);
      }).toList(),
      xAxisStartPoint: dataSet.xAxisStartPoint,
      xAxisEndPoint: dataSet.xAxisEndPoint,
      upperBaseline: upperBaseline != null
          ? ChartBaseline(
              dy: canvasSize.height +
                  padding.top +
                  (upperBaseline.dy - yMin) * -yRatio,
            )
          : null,
      lowerBaseline: lowerBaseline != null
          ? ChartBaseline(
              dy: canvasSize.height +
                  padding.top +
                  (lowerBaseline.dy - yMin) * -yRatio,
            )
          : null,
    );
  }
}
