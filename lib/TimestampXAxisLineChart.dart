// ignore_for_file: no_leading_underscores_for_local_identifiers, file_names

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:goodlinker_chart/TimestampXAxisChartBase.dart';
import 'package:goodlinker_chart/Utils.dart';
import 'package:goodlinker_chart/common/entry/ChartRuleLine.dart';
import 'package:goodlinker_chart/common/entry/TimestampXAxisData.dart';
import 'package:goodlinker_chart/common/entry/TimestampXAxisDataSet.dart';
import 'package:goodlinker_chart/usecases/CalculateOffsets.dart';

class TimestampXAxisLineChart extends StatefulWidget {
  final double axisLabelFontSize;

  const TimestampXAxisLineChart({
    Key? key,
    double? axisLabelFontSize,
    required this.dataSet,
  })  : axisLabelFontSize = axisLabelFontSize ?? 14,
        super(key: key);
  final TimestampXAxisDataSet dataSet;

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
        painter: _TimestampXAxisLineChartPainter(dataSet: widget.dataSet),
      ),
    );
  }
}

class _TimestampXAxisLineChartPainter extends CustomPainter {
  final TimestampXAxisDataSet dataSet;
  final Color limitAreaColor;
  final Color limitAreaLineColor;
  final Color normalAreaColor;
  final Color normalAreaLineColor;
  final double axisLabelFontSize;
  _TimestampXAxisLineChartPainter({
    required this.dataSet,
    Color? limitAreaLineColor,
    Color? limitAreaColor,
    Color? normalAreaLineColor,
    Color? normalAreaColor,
    double? axisLabelFontSize,
  })  : axisLabelFontSize = axisLabelFontSize ?? 14,
        limitAreaLineColor = limitAreaLineColor ?? Colors.red,
        limitAreaColor = limitAreaColor ?? Color.fromARGB(25, 239, 87, 38),
        normalAreaLineColor = normalAreaLineColor ?? Colors.green,
        normalAreaColor = normalAreaColor ?? Color.fromARGB(25, 7, 206, 63);
  late final double xAxisHeight = axisLabelFontSize + 2;
  late final double verticalPadding = 4;
  late final double horizontalPadding = 2;
  void _drawLastDataCircle({required Canvas canvas, required Size size}) {
    final safeAreaLinePaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2;
    final limitAreaLinePaint = Paint()
      ..color = Colors.red
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

    canvas.drawCircle(
        Offset(lastDataPoint.x.toDouble(), lastDataPoint.y), 4, circlePaint);
  }

  void _drawBaseline({required Canvas canvas, required Size size}) {
    final limitAreaLinePaint = Paint()..color = limitAreaLineColor;
    final limitAreaPaint = Paint()
      ..color = limitAreaColor
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;

    final Offset _originPoint = _getGraphAreaOriginOffset(size: size);
    final Size _drawingArea = _getGraphAreaSize(size: size);
// draw lower
    final newDataSet = CalculateOffsets().calculateOffsets(
        canvasSize: size,
        dataSet: dataSet,
        padding: EdgeInsets.fromLTRB(horizontalPadding, verticalPadding,
            horizontalPadding, verticalPadding),
        xAxisHeight: xAxisHeight);
    ChartRuleline? _lowerBaseline = newDataSet.lowerBaseline;
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
    ChartRuleline? _upperBaseline = newDataSet.upperBaseline;
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
  }

  void _drawLine({required Canvas canvas, required Size size}) {
    final safeAreaLinePaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2;
    final limitAreaLinePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2;
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
          log('nan srcOffset offset: $srcOffset');
          continue;
        }
        if (tarOffset.dy.isNaN) {
          log('nan tarOffset offset: $tarOffset');
          continue;
        }
        // log('srcOffset offset: $srcOffset');
        // log('tarOffset offset: $tarOffset');
        try {
          canvas.drawLine(srcOffset, tarOffset, safeAreaLinePaint);
        } catch (err, s) {
          log('srcOffset offset: $srcOffset');
          log('tarOffset offset: $tarOffset');
          log('srcOffset.dy == double.nan: ${srcOffset.dy.isNaN}');
          log('tarOffset.dy == double.nan: ${tarOffset.dy == double.nan}');

          print(err);
          print(s);
          continue;
        }
        // *********
        ChartRuleline? _upperBaseline = newDataSet.upperBaseline;
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
        ChartRuleline? _lowerBaseline = newDataSet.lowerBaseline;
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
    DateTime beginDateTime =
        DateTime.fromMillisecondsSinceEpoch(dataSet.xAxisStartPoint * 1000);
    String? beginLabel = beginDateTime.hourMinuteString();

    final TextSpan beginTextSpan = TextSpan(
      text: beginLabel,
      style: TextStyle(
        color: Colors.black,
        fontSize: 10,
      ),
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
      Offset(0, size.height - xAxisHeight),
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
      style: TextStyle(
        color: Colors.black,
        fontSize: 10,
      ),
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
      Offset(size.width / 2 - middleTextPainter.width / 2,
          size.height - xAxisHeight),
    );

    // ---------
    DateTime endDateTime =
        DateTime.fromMillisecondsSinceEpoch((dataSet.xAxisEndPoint) * 1000);
    String? endLabel = endDateTime.hourMinuteString();
    final TextSpan endTextSpan = TextSpan(
      text: endLabel,
      style: TextStyle(
        color: Colors.black,
        fontSize: 10,
      ),
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
      Offset(size.width - endTextPainter.width, size.height - xAxisHeight),
    );
  }

  void _drawAimLine({required Canvas canvas, required Size size}) {
    Paint aimLinePaint = Paint()
      ..color = Color.fromARGB(20, 33, 33, 33)
      ..strokeWidth = 2;
    canvas.drawLine(Offset(size.width / 2, size.height),
        Offset(size.width / 2, 0), aimLinePaint);
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
