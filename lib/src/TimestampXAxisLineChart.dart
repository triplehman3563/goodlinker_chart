// ignore_for_file: no_leading_underscores_for_local_identifiers, file_names

import 'package:flutter/material.dart';
import 'package:goodlinker_chart/src/entry/ChartRuleLine.dart';
import 'package:goodlinker_chart/src/entry/TimestampXAxisData.dart';
import 'package:goodlinker_chart/src/entry/TimestampXAxisDataSet.dart';
import 'package:goodlinker_chart/src/TimestampXAxisChartBase.dart';
import 'package:goodlinker_chart/src/Utils.dart';
import 'package:goodlinker_chart/src/usecases/ApplyPaddingUsecase.dart';
import 'package:goodlinker_chart/src/usecases/CalculateOffsets.dart';
import 'package:goodlinker_chart/src/style/LineChartStyle.dart';

class TimestampXAxisLineChart extends StatefulWidget {
  final LineChartStyle style;
  final EdgeInsets padding;

  /// Data which shows on chart
  final TimestampXAxisDataSet dataSet;

  TimestampXAxisLineChart({
    Key? key,
    double? axisLabelFontSize,
    required this.dataSet,
    LineChartStyle? style,
    EdgeInsets? padding,
  })  : padding = padding ?? EdgeInsets.fromLTRB(2, 4, 2, 4),
        style = style ?? LineChartStyle(),
        super(key: key);

  @override
  State<TimestampXAxisLineChart> createState() =>
      _TimestampXAxisLineChartState();
}

class _TimestampXAxisLineChartState extends State<TimestampXAxisLineChart> {
  @override
  Widget build(BuildContext context) {
    return TimestampXAxisChartBase(
      child: CustomPaint(
        size: Size.infinite,
        painter: _TimestampXAxisLineChartPainter(
            dataSet: widget.dataSet,
            style: widget.style,
            padding: widget.padding),
      ),
    );
  }
}

class _TimestampXAxisLineChartPainter extends CustomPainter {
  final LineChartStyle style;
  final TimestampXAxisDataSet dataSet;
  final EdgeInsets padding;

  _TimestampXAxisLineChartPainter(
      {required this.style, required this.dataSet, required this.padding});

  // limitAreaColor = limitAreaColor ?? Color.fromARGB(25, 239, 87, 38),

  late final double xAxisHeight = style.xAxisStyle.axisLabelFontSize + 2;
  late final double verticalPadding = padding.top;
  late final double horizontalPadding = padding.left;

  void _drawLastDataCircle({required Canvas canvas, required Size size}) {
    final safeAreaLinePaint = Paint()
      ..color = style.circleStyle.followLineColor
          ? style.lineStyle.normalColor
          : style.circleStyle.normalColor!
      ..strokeWidth = 2;
    final limitAreaLinePaint = Paint()
      ..color = style.circleStyle.followLineColor
          ? style.lineStyle.underMaskColor
          : style.circleStyle.underMaskColor!
      ..strokeWidth = 2;

    TimestampXAxisDataSet newDataSet = CalculateOffsets().calculateOffsets(
        canvasSize: size,
        dataSet: dataSet,
        padding: EdgeInsets.fromLTRB(horizontalPadding, verticalPadding,
            horizontalPadding, verticalPadding),
        xAxisHeight: xAxisHeight);
    final TimestampXAxisData lastDataPoint = newDataSet.data
        .reduce((value, element) => value.x > element.x ? value : element);
    var circlePaint = safeAreaLinePaint;
    final lowerBaseline = newDataSet.lowerBaseline;
    if (lowerBaseline != null) {
      if (lastDataPoint.y >= lowerBaseline.dy) {
        circlePaint = limitAreaLinePaint;
      }
    }
    final upperBaseline = newDataSet.upperBaseline;

    if (upperBaseline != null) {
      if (lastDataPoint.y <= upperBaseline.dy) {
        circlePaint = limitAreaLinePaint;
      }
    }

    canvas.drawCircle(Offset(lastDataPoint.x.toDouble(), lastDataPoint.y),
        style.circleStyle.size, circlePaint);

    Paint aimLinePaint = Paint()
      ..color = Color.fromARGB(20, 33, 33, 33)
      ..strokeWidth = 2;

    canvas.drawLine(
        Offset(lastDataPoint.x.toDouble(), size.height - xAxisHeight),
        Offset(lastDataPoint.x.toDouble(), 0),
        aimLinePaint);
  }

  void _drawBaseline({required Canvas canvas, required Size size}) {
    final limitAreaLinePaint = Paint()
      ..color = style.baseLineStyle.baselineColor;
    final limitAreaPaint = Paint()
      ..color = style.baseLineStyle.maskColor
      ..strokeWidth = style.baseLineStyle.width
      ..style = PaintingStyle.fill;
    final normalAreaPaint = Paint()..color = style.normalAreaColor;
    final Offset _originPoint = _getGraphAreaOriginOffset(size: size);
    final Size _drawingArea = _getGraphAreaSize(size: size);
// draw lower
    final newDataSet = CalculateOffsets().calculateOffsets(
        canvasSize: size,
        dataSet: dataSet,
        padding: EdgeInsets.fromLTRB(horizontalPadding, verticalPadding,
            horizontalPadding, verticalPadding),
        xAxisHeight: xAxisHeight);
    ChartBaseline? _lowerBaseline = newDataSet.lowerBaseline;
    if (_lowerBaseline != null) {
      final double lowerRuleLineY = _lowerBaseline.dy;
      canvas.drawRect(
          Rect.fromPoints(
            Offset(0, _originPoint.dy + verticalPadding),
            Offset(size.width, lowerRuleLineY),
          ),
          limitAreaPaint);

      canvas.drawLine(
        Offset(0, lowerRuleLineY),
        Offset(size.width, lowerRuleLineY),
        limitAreaLinePaint,
      );
    }
    // draw upper
    ChartBaseline? _upperBaseline = newDataSet.upperBaseline;
    if (_upperBaseline != null) {
      final double upperRuleLineY = _upperBaseline.dy;
      canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromPoints(
              Offset(
                0,
                _originPoint.dy - _drawingArea.height - verticalPadding,
              ),
              Offset(size.width, upperRuleLineY),
            ),
            Radius.circular(10),
          ),
          limitAreaPaint);
      canvas.drawLine(
        Offset(0, upperRuleLineY),
        Offset(size.width, upperRuleLineY),
        limitAreaLinePaint,
      );
    }
    // drawSafe
    canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromPoints(
            Offset(
                0,
                newDataSet.upperBaseline?.dy ??
                    (_originPoint.dy - _drawingArea.height - verticalPadding)),
            Offset(
                size.width,
                newDataSet.lowerBaseline?.dy ??
                    (_originPoint.dy + verticalPadding)),
          ),
          Radius.circular(10),
        ),
        normalAreaPaint);
  }

  void _drawLine({required Canvas canvas, required Size size}) {
    final safeAreaLinePaint = Paint()
      ..color = style.lineStyle.normalColor
      ..strokeWidth = style.lineStyle.width;
    final limitAreaLinePaint = Paint()
      ..color = style.lineStyle.underMaskColor
      ..strokeWidth = style.lineStyle.width;
    TimestampXAxisDataSet newDataSet = CalculateOffsets().calculateOffsets(
        canvasSize: size,
        dataSet: dataSet,
        padding: EdgeInsets.fromLTRB(horizontalPadding, verticalPadding,
            horizontalPadding, verticalPadding),
        xAxisHeight: xAxisHeight);
    TimestampXAxisData? _previousElement;
    for (var thisElement in newDataSet.data) {
      final _thisPreviousElement = _previousElement;
      if (_thisPreviousElement != null) {
        final Offset srcOffset =
            Offset(_thisPreviousElement.x.toDouble(), _thisPreviousElement.y);
        final Offset tarOffset =
            Offset(thisElement.x.toDouble(), thisElement.y);
        if (srcOffset.dy.isNaN) {
          continue;
        }
        if (tarOffset.dy.isNaN) {
          continue;
        }
        try {
          canvas.drawLine(srcOffset, tarOffset, safeAreaLinePaint);
        } catch (err) {
          continue;
        }
        // *********
        ChartBaseline? _upperBaseline = newDataSet.upperBaseline;
        if (_upperBaseline != null) {
          final topLine = _upperBaseline.dy;
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
                limitAreaLinePaint,
              );
            } else {
              canvas.drawLine(
                srcOffset,
                tarOffset,
                limitAreaLinePaint,
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
                limitAreaLinePaint,
              );
            }
          }
        }
        ChartBaseline? _lowerBaseline = newDataSet.lowerBaseline;
        if (_lowerBaseline != null) {
          final bottomLine = _lowerBaseline.dy;
          if (srcOffset.dy >= bottomLine) {
            if (tarOffset.dy >= bottomLine) {
              canvas.drawLine(
                srcOffset,
                tarOffset,
                limitAreaLinePaint,
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
                limitAreaLinePaint,
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
                limitAreaLinePaint,
              );
            }
          }
        }

// **********
      }

      _previousElement = thisElement;
    }
  }

  void _drawXAxis({required Canvas canvas, required Size size}) {
    // draw begin label
    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: style.xAxisStyle.axisLabelFontSize,
    );
    final canvasSize = ApplyPaddingUsecase().applyPadding(
        canvasSize: size, padding: padding, xAxisHeight: xAxisHeight);
    DateTime beginDateTime =
        DateTime.fromMillisecondsSinceEpoch(dataSet.xAxisStartPoint * 1000);
    String? beginLabel = beginDateTime.hourMinuteString();

    final TextSpan beginTextSpan = TextSpan(
      text: beginLabel,
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
      Offset(0 + padding.left, size.height - xAxisHeight),
    );
    // ---------

    DateTime middleDateTime = DateTime.fromMillisecondsSinceEpoch(
        (dataSet.xAxisStartPoint +
                    (dataSet.xAxisEndPoint - dataSet.xAxisStartPoint) / 2)
                .round() *
            1000);
    String? middleLabel = middleDateTime.hourMinuteString();
    final TextSpan middleTextSpan = TextSpan(
      text: middleLabel,
      style: textStyle,
    );

    final middleTextPainter = TextPainter(
      text: middleTextSpan,
      textDirection: TextDirection.ltr,
    );
    middleTextPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    middleTextPainter.paint(
      canvas,
      Offset(
          0 + padding.left + canvasSize.width / 2 - middleTextPainter.width / 2,
          size.height - xAxisHeight),
    );

    // ---------
    DateTime endDateTime =
        DateTime.fromMillisecondsSinceEpoch((dataSet.xAxisEndPoint) * 1000);
    String? endLabel = endDateTime.hourMinuteString();
    final TextSpan endTextSpan = TextSpan(
      text: endLabel,
      style: textStyle,
    );

    final endTextPainter = TextPainter(
      text: endTextSpan,
      textDirection: TextDirection.ltr,
    );
    endTextPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    endTextPainter.paint(
      canvas,
      Offset(0 + padding.left + canvasSize.width - endTextPainter.width,
          size.height - xAxisHeight),
    );
  }

  void _drawAimLine({required Canvas canvas, required Size size}) {
    Paint aimLinePaint = Paint()
      ..color = Color.fromARGB(20, 33, 33, 33)
      ..strokeWidth = 1;
    final canvasSize = ApplyPaddingUsecase().applyPadding(
        canvasSize: size, padding: padding, xAxisHeight: xAxisHeight);
    canvas.drawLine(
        Offset(padding.left + canvasSize.width / 2, size.height - xAxisHeight),
        Offset(size.width / 2, 0),
        aimLinePaint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawLine(canvas: canvas, size: size);
    _drawLastDataCircle(canvas: canvas, size: size);
    _drawBaseline(canvas: canvas, size: size);
    _drawAimLine(canvas: canvas, size: size);
    _drawXAxis(canvas: canvas, size: size);
  }

  @override
  bool shouldRepaint(_TimestampXAxisLineChartPainter oldDelegate) {
    return dataSet.data.length != oldDelegate.dataSet.data.length;
  }

  Size _getGraphAreaSize({required Size size}) => Size(
      size.width - 2 * horizontalPadding,
      size.height - 2 * verticalPadding - xAxisHeight);

  Offset _getGraphAreaOriginOffset({required Size size}) => Offset(
        0 + horizontalPadding,
        0 + size.height - verticalPadding - xAxisHeight,
      );
}
