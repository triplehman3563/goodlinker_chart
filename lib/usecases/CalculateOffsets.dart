// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:goodlinker_chart/common/entry/TimestampXAxisDataSet.dart';
import 'package:goodlinker_chart/usecases/ApplyPaddingUsecase.dart';
import 'package:goodlinker_chart/usecases/CoordinateTransferUsecase.dart';

class CalculateOffsets {
  TimestampXAxisDataSet calculateOffsets({
    required Size canvasSize,
    required TimestampXAxisDataSet dataSet,
    required EdgeInsets padding,
    required double xAxisHeight,
  }) {
    final size = ApplyPaddingUsecase().applyPadding(
        canvasSize: canvasSize, padding: padding, xAxisHeight: xAxisHeight);
    return CoordinateTransferUsecase().transferToCanvasCoor(
        dataSet: dataSet, canvasSize: size, padding: padding);
  }
}
