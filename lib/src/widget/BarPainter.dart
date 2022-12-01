import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:goodlinker_chart/src/GoodLinkerChartException.dart';
import 'package:goodlinker_chart/src/Utils.dart';
import 'package:goodlinker_chart/src/entry/NewData.dart';
import 'package:goodlinker_chart/src/style/BarChartStyle.dart';
import 'package:tuple/tuple.dart';

class BarPainter extends CustomPainter {
  final List<NewData> dataSet;
  final BarChartStyle barChartStyle;
  final String Function({int x})? xAxisLabelFormater;

  BarPainter({
    required this.dataSet,
    required this.barChartStyle,
    this.xAxisLabelFormater,
  });

  final double gridRatio = 3 / 7;
  late final double gridWidth;
  late final Offset drawingAreaOrigin;
  late final Size drawingAreaSize;

  late final double yAxisHeight;
  late final double yAxisWidth;

  late final double xAxisHeight;
  late final double xAxisWidth;

  late final int finalXLabelCount;

  late final int finalYLabelCount;

  @override
  void paint(Canvas canvas, Size size) {
    // What should the chart be like?
    // 1. draw entities when x and y have value.
    // 2. don't show bars but remains space when y is nan.
    // 3. draw bar when y is a valid double number.
    // 4. can adjust displaying x item length
    // 5. the displaying entities should sprey around middle horizon line.
    //
    //
    // 1. Calculate displaying items.
    //    There will be a line, entities will be seperate left and right.
    //    But do we really need to seperate them literally?
    // 2. Calculate drawing offset based on chart size and displaying items.
    // 3. Item should be draw from the mid horizon line, therefore if item has same y value, they align in the mid horizon.
    // 4. for x-axis, label shouldbe draw but not covering each other. With same scale if possible. getting an x-axis formator.
    // 5. for y axis, display label numbers as a range, i.g. 8~12, depends on scale ratio of chart and chart size.

    // 1. do the calculation.

    _calculateAxis(canvasSize: size);

    _calculateDrawingArea(canvasSize: size);

    _calculateBarWidth(drawingAreaSize: drawingAreaSize);
    _drawFrame(canvas: canvas, canvasSize: size);
    final List<Offset> drawingEntities = _calculateEntities(size);
    drawingEntities.asMap().forEach((index, entry) {
      if (entry.dy.isNaN) {
        return;
      }
      final Offset pointA = Offset(entry.dx - gridWidth * (1 - gridRatio) / 2,
          drawingAreaOrigin.dy + drawingAreaSize.height);
      final Offset pointB =
          Offset(entry.dx + gridWidth * (1 - gridRatio) / 2, entry.dy);
      canvas.drawRect(
          Rect.fromPoints(pointA, pointB), Paint()..color = Colors.green);
      log('pointA: $pointA, pointB: $pointB');
    });
  }

  void _calculateAxis({required Size canvasSize}) {
    List<NewData> calculatingData = dataSet;
    List<double> yDatas = calculatingData.map((e) => e.y).toList();
    double y_max = yDatas.max();
    final longestYLabel = yDatas
        .map((e) {
          return e.toString();
        })
        .toList()
        .reduce((value, element) =>
            value.length > element.length ? value : element);

    final TextSpan yAxisTextSpan = TextSpan(
      text: longestYLabel,
      style: TextStyle(),
    );
    final yAxisTextPainter = TextPainter(
      text: yAxisTextSpan,
      textDirection: TextDirection.ltr,
    );

    yAxisTextPainter.layout(
      minWidth: 0,
      maxWidth: canvasSize.width,
    );
    // y axis width
    this.yAxisWidth = yAxisTextPainter.width;
    // x axis width
    this.xAxisWidth = canvasSize.width - this.yAxisWidth;
    // x axis height
    double xFontLineHeight = barChartStyle.xAxisStyle.fontSize *
        barChartStyle.xAxisStyle.lineHeightFactor;

    this.xAxisHeight = xFontLineHeight;
    // y axis height
    this.yAxisHeight = canvasSize.height - this.xAxisHeight;

    // y label height
    double yFontLineHeight = barChartStyle.yAxisStyle.fontSize *
        barChartStyle.yAxisStyle.lineHeightFactor;
    final yAxisLabelHeight = yFontLineHeight;

    // how many y label should be shown?
    final double maxYLabelCount = this.yAxisHeight / yAxisLabelHeight;
    final double yLabelDenseFactor = 0.5;
    this.finalYLabelCount = (maxYLabelCount * yLabelDenseFactor).floor() < 1
        ? 1
        : (maxYLabelCount * yLabelDenseFactor).floor();

    // how many x label should be shown?
    List<int> xDatas = calculatingData.map((e) => e.x).toList();

    final String longestXLabel = xDatas
        .map((e) {
          return xAxisLabelFormater != null
              ? xAxisLabelFormater!(x: e)
              : e.toString();
        })
        .toList()
        .reduce((value, element) =>
            value.length > element.length ? value : element);

    final TextSpan xAxisTextSpan = TextSpan(
      text: longestXLabel,
      style: TextStyle(),
    );
    final xAxisTextPainter = TextPainter(
      text: xAxisTextSpan,
      textDirection: TextDirection.ltr,
    );

    xAxisTextPainter.layout(
      minWidth: 0,
      maxWidth: canvasSize.width,
    );
    final longestXLabelWidth = xAxisTextPainter.width;
    final double maxXLabelCount = this.xAxisWidth / longestXLabelWidth;
    final double xLabelDenseFactor = 0.5;

    this.finalXLabelCount = maxXLabelCount * xLabelDenseFactor < 1
        ? 1
        : (maxXLabelCount * xLabelDenseFactor).floor();
  }

  List<Offset> _calculateEntities(Size canvasSize) {
    final double canvasHeight = canvasSize.height;
    final double canvasWidth = canvasSize.width;
    // calculate drawingArea
    // vertical layers: 1. drawing area, 2. xAxis label area.
    // area 2's height depends on font height of label.

    final List<NewData> calculateEntities = dataSet;
    final int x_min = calculateEntities.map((e) => e.x).toList().min();
    final int x_max = calculateEntities.map((e) => e.x).toList().max();
    log('x_min = $x_min');
    log('x_max = $x_max');
    final double y_min = calculateEntities.map((e) => e.y).toList().min();
    final double y_max = calculateEntities.map((e) => e.y).toList().max();
    log('y_min = $y_min');
    log('y_max = $y_max');

    final double y_ratio = y_max == 0 ? 1 : drawingAreaSize.height / y_max;
    final double x_ratio = (x_max - x_min) == 0
        ? 1
        : (drawingAreaSize.width - gridWidth * (1 - gridRatio)) /
            (x_max - x_min);

    final List<Offset> drawingEntities = calculateEntities
        .map(
          (e) => Offset(
            drawingAreaOrigin.dx +
                (e.x - x_min) * x_ratio +
                gridWidth * (1 - gridRatio) / 2,
            drawingAreaOrigin.dy + drawingAreaSize.height - (e.y) * y_ratio,
          ),
        )
        .toList();
    return drawingEntities;
  }

  void _calculateBarWidth({required Size drawingAreaSize}) {
    final int entitiesLength = dataSet.length;
    this.gridWidth = drawingAreaSize.width / entitiesLength;
  }

  void _calculateDrawingArea({required Size canvasSize}) {
    final double xAXisHeight = barChartStyle.xAxisStyle.fontSize + 2;

    final double drawingAreaHeight =
        canvasSize.height - xAXisHeight - barChartStyle.innerPadding.vertical;
    final double drawingAreaWidth =
        canvasSize.width - barChartStyle.innerPadding.horizontal - yAxisWidth;
    assert(canvasSize.height > xAXisHeight ||
        (throw GoodLinkerChartException('canvas height too small')));
    this.drawingAreaOrigin =
        Offset(barChartStyle.innerPadding.left, barChartStyle.innerPadding.top);
    this.drawingAreaSize = Size(drawingAreaWidth, drawingAreaHeight);
  }

  void _drawFrame({required Canvas canvas, required Size canvasSize}) {
    Paint framePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke;
    // draw outter frame
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromPoints(
            Offset(0, 0),
            Offset(canvasSize.width - yAxisWidth, canvasSize.height),
          ),
          Radius.circular(15)),
      framePaint,
    );
    // draw xAxis frame
    canvas.drawLine(
      Offset(0, drawingAreaOrigin.dy + drawingAreaSize.height),
      Offset(canvasSize.width - yAxisWidth,
          drawingAreaOrigin.dy + drawingAreaSize.height),
      framePaint,
    );
  }

  @override
  bool shouldRepaint(BarPainter oldDelegate) {
    return oldDelegate.dataSet.length != dataSet.length;
  }
}
