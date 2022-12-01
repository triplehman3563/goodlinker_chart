import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:goodlinker_chart/src/entry/ChartRuleLine.dart';
import 'package:goodlinker_chart/src/entry/CartesianData.dart';
import 'package:goodlinker_chart/src/entry/CartesianEntry.dart';
import 'package:goodlinker_chart/src/entry/LineChartEntry.dart';
import 'package:goodlinker_chart/src/style/ChartStyle.dart';
import 'package:goodlinker_chart/src/Utils.dart';
import 'package:goodlinker_chart/src/usecases/contrast_color_calculate.dart';

class LinePainter extends CustomPainter {
  final ChartStyle style;
  final EdgeInsets padding;
  final CartesianData data;
  final double? upperLine;
  final double? lowerline;
  final double? minLine;
  final double? maxLine;
  final int currentMiddleDisplayIndex;
  final int currentDisplayRange;
  final bool dataFeedbackMode;
  final bool enableDrawLastDataCircle;
  final Offset lastTapLocation;
  final String Function(double value)? xAxisFormatter;
  final String Function(double value)? yAxisFormatter;
  void Function(LineChartEntry? entry, int selectIndex) dataSelectionCallback;
  LinePainter({
    required this.style,
    required this.data,
    required this.padding,
    required this.currentMiddleDisplayIndex,
    required this.currentDisplayRange,
    required this.dataFeedbackMode,
    required this.enableDrawLastDataCircle,
    required this.dataSelectionCallback,
    this.xAxisFormatter,
    this.yAxisFormatter,
    this.upperLine,
    this.lowerline,
    this.minLine,
    this.maxLine,
    Offset? lastTapLocation,
  }) : lastTapLocation = lastTapLocation ?? Offset(0, 0);
  late List<LineChartEntry> displayingEntities;
  late double maxYLabelWidth;
  late Offset dataDrawingAreaTopLeft;
  late Offset dataDrawingBottomRight;
  late Offset areaDrawingAreaTopLeft;
  late Offset areaDrawingBottomRight;

  late Size drawingAreaSize;
  late double yMax;
  late double yMin;
  late ChartBaseline? upperBaseline;
  late ChartBaseline? lowerBaseline;
  late ChartBaseline? minBaseLine;
  late ChartBaseline? maxBaseLine;

  @override
  bool shouldRepaint(LinePainter oldDelegate) {
    return data.entities.length != oldDelegate.data.entities.length ||
        currentMiddleDisplayIndex != oldDelegate.currentMiddleDisplayIndex ||
        currentDisplayRange != oldDelegate.currentDisplayRange ||
        dataFeedbackMode != oldDelegate.dataFeedbackMode ||
        lastTapLocation != oldDelegate.lastTapLocation;
  }

  @override
  void paint(Canvas canvas, Size size) {
    try {
      // _drawDebugInfo(canvas: canvas, size: size);
      displayingEntities = _calDisplayingEntities(size);
      _handleTap(canvas: canvas, size: size);
      _drawXAxis(canvas: canvas, size: size);
      _drawYAxis(canvas: canvas, size: size);
      _drawArea(canvas: canvas, size: size);
      _drawExtremeValue(canvas: canvas, size: size);
      _drawData(canvas: canvas, size: size);
      _drawDisplayingDataLine(canvas: canvas, size: size);
    } catch (err, s) {
      rethrow;
    }
  }

  void _drawData({required Canvas canvas, required Size size}) {
    Paint normalDataPaint = Paint()
      ..color = style.lineStyle.normalColor
      ..strokeWidth = style.lineStyle.dataLineWidth;
    Paint unMaskDataPaint = Paint()
      ..color = style.lineStyle.maskedColor
      ..strokeWidth = style.lineStyle.dataLineWidth;

    double widthRemain = 0;
    displayingEntities.asMap().forEach((index, entry) {
      if (index != 0) {
        final lastData = displayingEntities[index - 1];
        final pointWidth = entry.x - lastData.x;

        if (lastData.y == null || lastData.y == double.nan) {
        } else {
          final srcOffset = Offset(lastData.x, lastData.y ?? 0);
          final tarOffset = Offset(entry.x, entry.y ?? 0);
          if (srcOffset < dataDrawingAreaTopLeft &&
              tarOffset < dataDrawingAreaTopLeft) {
            // don't draw
          }
          if (srcOffset < dataDrawingAreaTopLeft &&
              tarOffset >= dataDrawingAreaTopLeft) {
            // crossing drawing border left top out->in
          }

          if (srcOffset >= dataDrawingAreaTopLeft &&
              tarOffset >= dataDrawingAreaTopLeft &&
              srcOffset <= dataDrawingBottomRight &&
              tarOffset <= dataDrawingBottomRight) {
            // draw normally
            canvas.drawLine(srcOffset, tarOffset, normalDataPaint);
            ChartBaseline? thisUpperBaseline = upperBaseline;
            if (thisUpperBaseline != null) {
              final topLine = thisUpperBaseline.dy;
              if (srcOffset.dy <= topLine) {
                if (tarOffset.dy >= topLine) {
                  final lowerPointAtTopLimit = Offset(
                      srcOffset.dx +
                          ((tarOffset.dx - srcOffset.dx) *
                              (topLine - srcOffset.dy) /
                              ((tarOffset.dy - srcOffset.dy) == 0
                                  ? 1
                                  : tarOffset.dy - srcOffset.dy)),
                      topLine);
                  canvas.drawLine(
                    srcOffset,
                    lowerPointAtTopLimit,
                    unMaskDataPaint,
                  );
                } else {
                  canvas.drawLine(
                    srcOffset,
                    tarOffset,
                    unMaskDataPaint,
                  );
                }
              }
              if (tarOffset.dy <= topLine) {
                if (srcOffset.dy >= topLine) {
                  final lowerPointAtLowerLimit = Offset(
                      srcOffset.dx +
                          ((tarOffset.dx - srcOffset.dx) *
                              (topLine - srcOffset.dy) /
                              ((tarOffset.dy - srcOffset.dy) == 0
                                  ? 1
                                  : tarOffset.dy - srcOffset.dy)),
                      topLine);
                  canvas.drawLine(
                    lowerPointAtLowerLimit,
                    tarOffset,
                    unMaskDataPaint,
                  );
                }
              }
            }
            ChartBaseline? thisLowerBaseline = lowerBaseline;
            if (thisLowerBaseline != null) {
              final bottomLine = thisLowerBaseline.dy;
              if (srcOffset.dy >= bottomLine) {
                if (tarOffset.dy >= bottomLine) {
                  canvas.drawLine(
                    srcOffset,
                    tarOffset,
                    unMaskDataPaint,
                  );
                } else {
                  final lowerPointAtLowerLimit = Offset(
                      srcOffset.dx +
                          ((tarOffset.dx - srcOffset.dx) *
                              (bottomLine - srcOffset.dy) /
                              ((tarOffset.dy - srcOffset.dy) == 0
                                  ? 1
                                  : tarOffset.dy - srcOffset.dy)),
                      bottomLine);

                  canvas.drawLine(
                    srcOffset,
                    lowerPointAtLowerLimit,
                    unMaskDataPaint,
                  );
                }
              }
              if (tarOffset.dy >= bottomLine) {
                if (srcOffset.dy >= bottomLine) {
                } else {
                  final lowerPointAtLowerLimit = Offset(
                      srcOffset.dx +
                          ((tarOffset.dx - srcOffset.dx) *
                              (bottomLine - srcOffset.dy) /
                              ((tarOffset.dy - srcOffset.dy) == 0
                                  ? 1
                                  : tarOffset.dy - srcOffset.dy)),
                      bottomLine);
                  canvas.drawLine(
                    lowerPointAtLowerLimit,
                    tarOffset,
                    unMaskDataPaint,
                  );
                }
              }
            }
          }
          if (srcOffset <= dataDrawingBottomRight &&
              tarOffset > dataDrawingBottomRight) {
            // crossing drawing border right bottom in->out
          }
          if (srcOffset > dataDrawingBottomRight &&
              tarOffset > dataDrawingBottomRight) {
            // don't draw
          }

          if (srcOffset >= dataDrawingAreaTopLeft &&
              srcOffset <= dataDrawingBottomRight &&
              tarOffset >= dataDrawingAreaTopLeft &&
              tarOffset <= dataDrawingBottomRight) {}

          if (widthRemain >= 0) {
            final thisDraw = _drawXAxisLabel(
              canvas: canvas,
              size: size,
              index: index,
              src: srcOffset,
              tar: tarOffset,
              xData: lastData.originEntry.x ?? 0,
            );
            if ((pointWidth - thisDraw.width) > 0) {
            } else {
              widthRemain = pointWidth - thisDraw.width;
            }
          } else {
            widthRemain = widthRemain + pointWidth;
          }
        }
      }
    });
  }

  void _drawExtremeValue({required Canvas canvas, required Size size}) {
    Paint maxValuePaint = Paint()
      ..color = style.lineStyle.maxValueColor
      ..strokeWidth = style.lineStyle.dataLineWidth;

    Paint minValuePaint = Paint()
      ..color = style.lineStyle.minValueColor
      ..strokeWidth = style.lineStyle.dataLineWidth;

    TextStyle textStyle = TextStyle(
      color: Colors.white,
      fontSize: style.xAxisStyle.axisLabelFontSize,
      // fontSize: 14,
    );

    ChartBaseline? thisMaxLine = maxBaseLine;
    if (thisMaxLine != null && !thisMaxLine!.dy.isNaN) {
      if (thisMaxLine.dy <= size.height && thisMaxLine.dy >= 0) {
        final TextSpan axisTextSpan = TextSpan(
          text: maxLine?.toStringAsFixed(1),
          style: textStyle.copyWith(color: ContrastColorCalculate()
                  .determinemonochromeFontColorFromBackground(backgroundColor: maxValuePaint.color)),
        );
        final axisTextPainter = TextPainter(
          text: axisTextSpan,
          textDirection: TextDirection.ltr,
        );
        axisTextPainter.layout(
          minWidth: 0,
          maxWidth: size.width,
        );
        // drawing top extreme value y label on y axis
        canvas.drawLine(
          Offset(areaDrawingBottomRight.dx, thisMaxLine.dy),
          Offset(areaDrawingBottomRight.dx + 5, thisMaxLine.dy),
          Paint(),
        );
        canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromPoints(
                Offset(areaDrawingBottomRight.dx + 6,
                    thisMaxLine.dy - axisTextPainter.height / 2 - 2),
                Offset(
                    areaDrawingBottomRight.dx + 10 + axisTextPainter.width,
                    thisMaxLine.dy -
                        axisTextPainter.height / 2 +
                        axisTextPainter.height +
                        2),
              ),
              Radius.circular(4),
            ),
            maxValuePaint);
        axisTextPainter.paint(
          canvas,
          Offset(areaDrawingBottomRight.dx + 8,
              thisMaxLine.dy - axisTextPainter.height / 2),
        );
        // drawing top extreme value line
        double dottedLineWidth = 1, dottedLineSpace = 1;
        double startX = areaDrawingAreaTopLeft.dx;
        while (startX < areaDrawingBottomRight.dx) {
          canvas.drawLine(
            Offset(startX, thisMaxLine.dy),
            Offset(startX + dottedLineWidth, thisMaxLine.dy),
            maxValuePaint,
          );
          startX += dottedLineWidth + dottedLineSpace;
        }
        // canvas.drawLine(
        //   Offset(areaDrawingAreaTopLeft.dx, thisMaxLine.dy),
        //   Offset(areaDrawingBottomRight.dx, thisMaxLine.dy),
        //   maxValuePaint,
        // );
      }
    }
    ChartBaseline? thisMinLine = minBaseLine;
    if (thisMinLine != null && !thisMinLine!.dy.isNaN) {
      if (thisMinLine.dy <= size.height && thisMinLine.dy >= 0) {
        final TextSpan axisTextSpan = TextSpan(
          text: minLine?.toStringAsFixed(1),
          style: textStyle.copyWith(
              color: ContrastColorCalculate()
                  .determinemonochromeFontColorFromBackground(
                      backgroundColor: minValuePaint.color)),
        );
        final axisTextPainter = TextPainter(
          text: axisTextSpan,
          textDirection: TextDirection.ltr,
        );
        axisTextPainter.layout(
          minWidth: 0,
          maxWidth: size.width,
        );
        // drawing bottom extreme value y label on y axis

        canvas.drawLine(
          Offset(areaDrawingBottomRight.dx, thisMinLine.dy),
          Offset(areaDrawingBottomRight.dx + 5, thisMinLine.dy),
          Paint(),
        );
        canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromPoints(
                Offset(areaDrawingBottomRight.dx + 6,
                    thisMinLine.dy - axisTextPainter.height / 2 - 2),
                Offset(
                    areaDrawingBottomRight.dx + 10 + axisTextPainter.width,
                    thisMinLine.dy -
                        axisTextPainter.height / 2 +
                        axisTextPainter.height +
                        2),
              ),
              Radius.circular(4),
            ),
            minValuePaint);
        axisTextPainter.paint(
          canvas,
          Offset(areaDrawingBottomRight.dx + 8,
              thisMinLine.dy - axisTextPainter.height / 2),
        );
        // drawing bottom extreme value line

        double dottedLineWidth = 1, dottedLineSpace = 1;
        double startX = areaDrawingAreaTopLeft.dx;
        while (startX < areaDrawingBottomRight.dx) {
          canvas.drawLine(
            Offset(startX, thisMinLine.dy),
            Offset(startX + dottedLineWidth, thisMinLine.dy),
            maxValuePaint,
          );
          startX += dottedLineWidth + dottedLineSpace;
        }

        // canvas.drawLine(
        //   Offset(areaDrawingAreaTopLeft.dx, thisMinLine.dy),
        //   Offset(areaDrawingBottomRight.dx, thisMinLine.dy),
        //   minValuePaint,
        // );
      }
    }
  }

  void _drawArea({required Canvas canvas, required Size size}) {
    Paint normalAreaPaint = Paint()
      ..color = style.lineStyle.normalColor.withAlpha(25);
    Paint maskAreaPaint = Paint()
      ..color = style.lineStyle.maskedColor.withAlpha(25);
    Paint limitLinePaint = Paint()
      ..color = style.lineStyle.maskedColor
      ..strokeWidth = style.lineStyle.dataLineWidth;
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: style.xAxisStyle.axisLabelFontSize,
      // fontSize: 14,
    );

    try {
      canvas.drawRect(
        Rect.fromPoints(
          Offset(
            areaDrawingAreaTopLeft.dx,
            upperBaseline != null && !upperBaseline!.dy.isNaN
                ? upperBaseline!.dy
                : 0,
          ),
          Offset(
            areaDrawingBottomRight.dx,
            lowerBaseline != null && !upperBaseline!.dy.isNaN
                ? lowerBaseline!.dy
                : areaDrawingBottomRight.dy,
          ),
        ),
        normalAreaPaint,
      );
    } catch (err, s) {
      rethrow;
    }

    ChartBaseline? thisUpperBaseline = upperBaseline;
    if (thisUpperBaseline != null && !thisUpperBaseline!.dy.isNaN) {
      final TextSpan axisTextSpan = TextSpan(
        text: upperLine?.toStringAsFixed(1),
        style: textStyle.copyWith(
              color: ContrastColorCalculate()
                  .determinemonochromeFontColorFromBackground(
                      backgroundColor: limitLinePaint.color)),
      );
      final axisTextPainter = TextPainter(
        text: axisTextSpan,
        textDirection: TextDirection.ltr,
      );
      axisTextPainter.layout(
        minWidth: 0,
        maxWidth: size.width,
      );
      canvas.drawLine(
        Offset(areaDrawingBottomRight.dx, thisUpperBaseline.dy),
        Offset(areaDrawingBottomRight.dx + 5, thisUpperBaseline.dy),
        Paint(),
      );
      canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromPoints(
              Offset(areaDrawingBottomRight.dx + 6,
                  thisUpperBaseline.dy - axisTextPainter.height / 2 - 2),
              Offset(
                  areaDrawingBottomRight.dx + 10 + axisTextPainter.width,
                  thisUpperBaseline.dy -
                      axisTextPainter.height / 2 +
                      axisTextPainter.height +
                      2),
            ),
            Radius.circular(4),
          ),
          limitLinePaint);
      axisTextPainter.paint(
        canvas,
        Offset(areaDrawingBottomRight.dx + 8,
            thisUpperBaseline.dy - axisTextPainter.height / 2),
      );
      // drawing upper base line
      double dottedLineWidth = 1, dottedLineSpace = 1;
      double startX = areaDrawingAreaTopLeft.dx;
      while (startX < areaDrawingBottomRight.dx) {
        canvas.drawLine(
          Offset(startX, thisUpperBaseline.dy),
          Offset(startX + dottedLineWidth, thisUpperBaseline.dy),
          limitLinePaint,
        );
        startX += dottedLineWidth + dottedLineSpace;
      }
      // canvas.drawLine(
      //   Offset(areaDrawingAreaTopLeft.dx, thisUpperBaseline.dy),
      //   Offset(areaDrawingBottomRight.dx, thisUpperBaseline.dy),
      //   limitLinePaint,
      // );

      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromPoints(
            areaDrawingAreaTopLeft,
            Offset(areaDrawingBottomRight.dx, thisUpperBaseline.dy),
          ),
          topLeft: Radius.circular(4),
          topRight: Radius.circular(4),
        ),
        maskAreaPaint,
      );
    }
    ChartBaseline? thisLowerBaseline = lowerBaseline;
    if (thisLowerBaseline != null && !thisLowerBaseline!.dy.isNaN) {
      final TextSpan axisTextSpan = TextSpan(
        text: lowerline?.toStringAsFixed(1),
        style: textStyle.copyWith(
              color: ContrastColorCalculate()
                  .determinemonochromeFontColorFromBackground(
                      backgroundColor: limitLinePaint.color)),
      );
      final axisTextPainter = TextPainter(
        text: axisTextSpan,
        textDirection: TextDirection.ltr,
      );
      axisTextPainter.layout(
        minWidth: 0,
        maxWidth: size.width,
      );
      canvas.drawLine(
        Offset(areaDrawingBottomRight.dx, thisLowerBaseline.dy),
        Offset(areaDrawingBottomRight.dx + 5, thisLowerBaseline.dy),
        Paint(),
      );
      canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromPoints(
              Offset(areaDrawingBottomRight.dx + 6,
                  thisLowerBaseline.dy - axisTextPainter.height / 2 - 2),
              Offset(
                  areaDrawingBottomRight.dx + 10 + axisTextPainter.width,
                  thisLowerBaseline.dy -
                      axisTextPainter.height / 2 +
                      axisTextPainter.height +
                      2),
            ),
            Radius.circular(4),
          ),
          limitLinePaint);
      axisTextPainter.paint(
        canvas,
        Offset(
          areaDrawingBottomRight.dx + 8,
          thisLowerBaseline.dy - axisTextPainter.height / 2,
        ),
      );
      // drawing lower base line
      double dottedLineWidth = 1, dottedLineSpace = 1;
      double startX = areaDrawingAreaTopLeft.dx;
      while (startX < areaDrawingBottomRight.dx) {
        canvas.drawLine(
          Offset(startX, thisLowerBaseline.dy),
          Offset(startX + dottedLineWidth, thisLowerBaseline.dy),
          limitLinePaint,
        );
        startX += dottedLineWidth + dottedLineSpace;
      }

      // canvas.drawLine(
      //   Offset(areaDrawingAreaTopLeft.dx, thisLowerBaseline.dy),
      //   Offset(areaDrawingBottomRight.dx, thisLowerBaseline.dy),
      //   limitLinePaint,
      // );
      canvas.drawRect(
        Rect.fromPoints(
          Offset(areaDrawingAreaTopLeft.dx, thisLowerBaseline.dy),
          areaDrawingBottomRight,
        ),
        maskAreaPaint,
      );
    }
  }

  void _drawYAxis({required Canvas canvas, required Size size}) {
    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: style.xAxisStyle.axisLabelFontSize,
      // fontSize: 14,
    );

    final int drawingStep;

    if (size.height / 4 < 100) {
      // draw 4 steps
      drawingStep = 4;
    } else {
      // draw 8 steps
      drawingStep = 8;
    }
    final stepHeight = drawingAreaSize.height / drawingStep;
    final stepYValue = (yMax - yMin) / drawingStep;
    for (int i = 0; i <= drawingStep; i++) {
      final String Function(double)? thisYAxisFormatter = yAxisFormatter;
      String axisText;
      if (thisYAxisFormatter != null) {
        axisText = thisYAxisFormatter(yMin + stepYValue * i);
      } else {
        axisText = (yMin + stepYValue * i).toStringAsFixed(1);
      }
      final TextSpan axisTextSpan = TextSpan(
        text: axisText,
        style: textStyle,
      );
      final axisTextPainter = TextPainter(
        text: axisTextSpan,
        textDirection: TextDirection.ltr,
      );

      axisTextPainter.layout(
        minWidth: 0,
        maxWidth: maxYLabelWidth,
      );
      canvas.drawLine(
        Offset(areaDrawingBottomRight.dx,
            dataDrawingBottomRight.dy - i * stepHeight),
        Offset(areaDrawingBottomRight.dx + 5,
            dataDrawingBottomRight.dy - i * stepHeight),
        Paint(),
      );
      axisTextPainter.paint(
        canvas,
        Offset(
            areaDrawingBottomRight.dx + 8,
            dataDrawingBottomRight.dy -
                i * stepHeight -
                axisTextPainter.height / 2),
      );
    }
  }

  void _drawXAxis({required Canvas canvas, required Size size}) {
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromPoints(
          Offset(
              areaDrawingAreaTopLeft.dx,
              size.height -
                  (style.xAxisStyle.axisLabelFontSize + 2) -
                  padding.bottom),
          Offset(areaDrawingBottomRight.dx, size.height),
        ),
        bottomLeft: Radius.circular(4),
        bottomRight: Radius.circular(4),
      ),

      // Paint()..color = Colors.red,
      Paint()..color = style.xAxisStyle.backgroundColor,
    );
    canvas.drawLine(
        Offset(
            areaDrawingAreaTopLeft.dx,
            size.height -
                (style.xAxisStyle.axisLabelFontSize + 2) -
                padding.bottom),
        Offset(
            areaDrawingBottomRight.dx,
            size.height -
                (style.xAxisStyle.axisLabelFontSize + 2) -
                padding.bottom),
        Paint()..color = style.xAxisStyle.axisBorderLineColor);
  }

  _LastLabel _drawXAxisLabel(
      {required Canvas canvas,
      required Size size,
      required int index,
      required Offset src,
      required Offset tar,
      required double xData}) {
    final xAxisHeight = style.xAxisStyle.axisLabelFontSize + 2;

    final textStyle = TextStyle(
      color: style.xAxisStyle.textColor,
      fontSize: style.xAxisStyle.axisLabelFontSize,
    );
    final String Function(double)? thisXAxisFormatter = xAxisFormatter;

    String axisText;
    if (thisXAxisFormatter != null) {
      axisText = thisXAxisFormatter(xData);
    } else {
      axisText = '$xData';
    }

    final TextSpan axisTextSpan = TextSpan(
      text: axisText,
      style: textStyle,
    );

    final axisTextPainter = TextPainter(
      text: axisTextSpan,
      textDirection: TextDirection.ltr,
    );

    axisTextPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );

    axisTextPainter.paint(
      canvas,
      Offset(src.dx, size.height - xAxisHeight),
    );
    return _LastLabel(width: axisTextPainter.width, offset: src);
  }

  void _drawDisplayingDataLine({required Canvas canvas, required Size size}) {
    if (dataFeedbackMode) {
      int selectIndex =
          (lastTapLocation.dx / size.width * displayingEntities.length)
              .round()
              .clamp(0, displayingEntities.length - 1);
      final int thisDataSelectIndex = selectIndex;
      canvas.drawLine(
        Offset(displayingEntities[thisDataSelectIndex].x, 0),
        Offset(displayingEntities[thisDataSelectIndex].x, size.height),
        Paint()
          ..color = Colors.blue
          ..strokeWidth = 2,
      );
    }
  }

  void _handleTap({required Canvas canvas, required Size size}) {
    if (dataFeedbackMode) {
      int selectIndex =
          (lastTapLocation.dx / size.width * displayingEntities.length)
              .round()
              .clamp(0, displayingEntities.length - 1);
      dataSelectionCallback(displayingEntities[selectIndex], selectIndex);
    } else {
      dataSelectionCallback(null, 0);
    }
  }

  List<LineChartEntry> _calDisplayingEntities(Size size) {
    List<CartesianEntry?> entitiesOnLeft = data.entities.sublist(
      (currentMiddleDisplayIndex - currentDisplayRange / 2) < 0
          ? 0
          : (currentMiddleDisplayIndex - currentDisplayRange / 2).ceil(),
      currentMiddleDisplayIndex,
    );
    entitiesOnLeft.insertAll(
        0,
        Iterable<CartesianEntry>.generate(
            (currentDisplayRange / 2 - entitiesOnLeft.length).floor(),
            (index) => CartesianEntry()).toList());

    List<CartesianEntry?> entitiesOnRight = data.entities.sublist(
      currentMiddleDisplayIndex,
      (currentMiddleDisplayIndex + currentDisplayRange / 2 - 1).ceil() >=
              data.entities.length
          ? null
          : (currentMiddleDisplayIndex + currentDisplayRange / 2 - 1).ceil(),
    );

    entitiesOnRight = entitiesOnRight +
        Iterable<CartesianEntry>.generate(
            (currentDisplayRange / 2 - entitiesOnRight.length + 1).floor(),
            (index) => CartesianEntry()).toList();

    final List<CartesianEntry?> displayingEntities =
        entitiesOnLeft + entitiesOnRight;

    List<double?> yDatas = displayingEntities.map((e) => e?.y).toList();
    yDatas.addAll([upperLine, lowerline]);
    maxYLabelWidth = _calMaxYAxisLabelWidth(size: size, yDatas: yDatas);
    _calDrawingArea(size: size);

    drawingAreaSize = Size(
      dataDrawingBottomRight.dx - dataDrawingAreaTopLeft.dx,
      dataDrawingBottomRight.dy - dataDrawingAreaTopLeft.dy,
    );

    final finalYDatas = yDatas.whereType<double>().toList();
    yMax = finalYDatas.max();
    yMin = finalYDatas.min();
    final yRange = yMax - yMin;
    final middleXPos = drawingAreaSize.width / 2;
    final xUnit = drawingAreaSize.width / displayingEntities.length;
    final yUnit = drawingAreaSize.height / yRange;

    upperBaseline = upperLine != null
        ? ChartBaseline(
            dy: dataDrawingAreaTopLeft.dy +
                drawingAreaSize.height -
                (upperLine! - yMin) * yUnit)
        : null;

    lowerBaseline = lowerline != null
        ? ChartBaseline(
            dy: dataDrawingAreaTopLeft.dy +
                drawingAreaSize.height -
                (lowerline! - yMin) * yUnit)
        : null;
    minBaseLine = minLine != null
        ? ChartBaseline(
            dy: dataDrawingAreaTopLeft.dy +
                drawingAreaSize.height -
                (minLine! - yMin) * yUnit)
        : null;

    maxBaseLine = maxLine != null
        ? ChartBaseline(
            dy: dataDrawingAreaTopLeft.dy +
                drawingAreaSize.height -
                (maxLine! - yMin) * yUnit)
        : null;

    final List<LineChartEntry> offsetLeft = entitiesOnLeft
        .asMap()
        .map((index, entry) {
          final disFromMid = (entitiesOnLeft.length - index - 1) * xUnit;
          final dx = dataDrawingAreaTopLeft.dx + middleXPos - disFromMid;
          final dy = entry?.y == null
              ? null
              : dataDrawingAreaTopLeft.dy +
                  drawingAreaSize.height -
                  (entry!.y! - yMin) * yUnit;
          return MapEntry(
            index,
            LineChartEntry(
              x: dx,
              y: dy,
              originEntry: entry ??
                  CartesianEntry(x: entry?.x, y: entry?.y, data: entry?.data),
            ),
          );
        })
        .values
        .toList();
    final List<LineChartEntry> offsetRight = entitiesOnRight
        .asMap()
        .map((index, entry) {
          final disFromMid = (index) * xUnit;
          final dx = dataDrawingAreaTopLeft.dx + middleXPos + disFromMid;
          final dy = entry?.y == null
              ? null
              : dataDrawingAreaTopLeft.dy +
                  drawingAreaSize.height -
                  (entry!.y! - yMin) * yUnit;
          return MapEntry(
            index,
            LineChartEntry(
              x: dx,
              y: dy,
              originEntry: entry ??
                  CartesianEntry(x: entry?.x, y: entry?.y, data: entry?.data),
            ),
          );
        })
        .values
        .toList();
    return offsetLeft + offsetRight;
  }

  void _calDrawingArea({required Size size}) {
    final xAxisHeight = style.xAxisStyle.axisLabelFontSize + 2;
    final yAxisTopPadding = 12;
    final yAxisBottomPadding = 12;

    final availableDrawingArea = Size(
      size.width - maxYLabelWidth,
      size.height - xAxisHeight - yAxisTopPadding - yAxisBottomPadding,
    );
    dataDrawingAreaTopLeft = Offset(
      padding.left + 8,
      padding.top + yAxisTopPadding.toDouble(),
    );
    dataDrawingBottomRight = Offset(
      availableDrawingArea.width - padding.right - 8,
      yAxisTopPadding.toDouble() + availableDrawingArea.height - padding.bottom,
    );
    areaDrawingAreaTopLeft = Offset(
      padding.left,
      padding.top,
    );
    areaDrawingBottomRight = Offset(
      size.width - padding.right - maxYLabelWidth,
      size.height - xAxisHeight - padding.bottom,
    );
  }

  double _calMaxYAxisLabelWidth(
      {required Size size, required List<double?> yDatas}) {
    double maxWidth = 0;
    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: style.xAxisStyle.axisLabelFontSize,
      // fontSize: 14,
    );
    for (var element in yDatas) {
      final TextSpan axisTextSpan = TextSpan(
        text: '$element',
        style: textStyle,
      );
      final axisTextPainter = TextPainter(
        text: axisTextSpan,
        textDirection: TextDirection.ltr,
      );
      axisTextPainter.layout(
        minWidth: 0,
        maxWidth: size.width,
      );
      if (maxWidth < axisTextPainter.width) {
        maxWidth = axisTextPainter.width;
      }
    }
    return maxWidth + 5;
  }

  // ignore: unused_element
  void _drawDebugInfo({required Canvas canvas, required Size size}) {
    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: 14,
    );

    final TextSpan beginTextSpan = TextSpan(
      text:
          'currentMiddleDisplayIndex: $currentMiddleDisplayIndex \ncurrentDisplayRange: $currentDisplayRange \nlastTapLocation: $lastTapLocation\ndataFeedbackMode: $dataFeedbackMode',
      style: textStyle,
    );

    final beginTextPainter = TextPainter(
      text: beginTextSpan,
      textDirection: TextDirection.ltr,
    );
    beginTextPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );

    beginTextPainter.paint(
      canvas,
      Offset(0, 0),
    );
    // ---------
  }
}

class _LastLabel {
  final double width;
  final Offset offset;
  _LastLabel({
    required this.width,
    required this.offset,
  });
}
