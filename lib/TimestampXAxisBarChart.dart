// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:goodlinker_chart/TimestampXAxisChartBase.dart';
import 'package:goodlinker_chart/Utils.dart';
import 'package:goodlinker_chart/common/entry/ChartRuleLine.dart';
import 'package:goodlinker_chart/common/entry/TimestampXAxisDataSet.dart';
import 'package:goodlinker_chart/usecases/ApplyPaddingUsecase.dart';
import 'package:goodlinker_chart/usecases/CalculateOffsets.dart';

class TimestampXAxisBarChart extends StatefulWidget {
  TimestampXAxisBarChart({
    Key? key,
    required this.dataSet,
  }) : super(key: key);
  final TimestampXAxisDataSet dataSet;

  @override
  State<TimestampXAxisBarChart> createState() => _TimestampXAxisBarChartState();
}

class _TimestampXAxisBarChartState extends State<TimestampXAxisBarChart> {
  @override
  Widget build(BuildContext context) {
    return TimestampXAxisChartBase(
      child: CustomPaint(
        painter: _TimestampXAxisBarChartPainter(dataSet: widget.dataSet),
      ),
    );
  }
}

class _TimestampXAxisBarChartPainter extends CustomPainter {
  final TimestampXAxisDataSet dataSet;
  final Color limitAreaColor;
  final Color limitAreaLineColor;
  final Color normalAreaColor;
  final Color normalAreaLineColor;
  final double axisLabelFontSize;
  _TimestampXAxisBarChartPainter({
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

  void _drawBaseline({required Canvas canvas, required Size size}) {
    final limitAreaLinePaint = Paint()..color = limitAreaLineColor;
    final limitAreaPaint = Paint()
      ..color = limitAreaColor
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;

    final Offset originPoint = _getGraphAreaOriginOffset(size: size);
    final Size drawingArea = _getGraphAreaSize(size: size);
// draw lower
    final newDataSet = CalculateOffsets().calculateOffsets(
        canvasSize: size,
        dataSet: dataSet,
        padding: EdgeInsets.fromLTRB(horizontalPadding, verticalPadding,
            horizontalPadding, verticalPadding),
        xAxisHeight: xAxisHeight);
    ChartRuleline? lowerBaseline = newDataSet.lowerBaseline;
    if (lowerBaseline != null) {
      final double lowerRuleLineY = lowerBaseline.dy;
      canvas.drawRect(
          Rect.fromPoints(
            Offset(0, originPoint.dy + verticalPadding),
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
    ChartRuleline? upperBaseline = newDataSet.upperBaseline;
    if (upperBaseline != null) {
      final double upperRuleLineY = upperBaseline.dy;
      canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromPoints(
              Offset(
                0,
                originPoint.dy - drawingArea.height - verticalPadding,
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
    final canvasSize = ApplyPaddingUsecase().applyPadding(
        canvasSize: size,
        padding: EdgeInsets.fromLTRB(horizontalPadding, verticalPadding,
            horizontalPadding, verticalPadding),
        xAxisHeight: xAxisHeight);
    final barWidth = (size.width - horizontalPadding * 2) / dataSet.data.length;
    for (var thisElement in newDataSet.data) {
      canvas.drawRect(
          Rect.fromPoints(
              Offset(thisElement.x.toDouble() - barWidth * 0.5,
                  canvasSize.height + verticalPadding),
              Offset(thisElement.x.toDouble() + barWidth, thisElement.y)),
          safeAreaLinePaint);
      final lowerBaseline = newDataSet.lowerBaseline?.dy;
      if (lowerBaseline != null) {
        if (thisElement.y >= lowerBaseline) {
          canvas.drawRect(
              Rect.fromPoints(
                  Offset(thisElement.x.toDouble() - barWidth * 0.5,
                      canvasSize.height + verticalPadding),
                  Offset(thisElement.x.toDouble() + barWidth, thisElement.y)),
              limitAreaLinePaint);
        } else {
          canvas.drawRect(
              Rect.fromPoints(
                  Offset(thisElement.x.toDouble() - barWidth * 0.5,
                      canvasSize.height + verticalPadding),
                  Offset(thisElement.x.toDouble() + barWidth, lowerBaseline)),
              limitAreaLinePaint);
        }
      }
      final upperBaseline = newDataSet.upperBaseline?.dy;

      if (upperBaseline != null) {
        if (thisElement.y <= upperBaseline) {
          canvas.drawRect(
              Rect.fromPoints(
                  Offset(
                      thisElement.x.toDouble() - barWidth * 0.5, upperBaseline),
                  Offset(thisElement.x.toDouble() + barWidth, thisElement.y)),
              limitAreaLinePaint);
        }
      }
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
    _drawBaseline(canvas: canvas, size: size);
    _drawAimLine(canvas: canvas, size: size);
    _drawXAxis(canvas: canvas, size: size);
  }

  @override
  bool shouldRepaint(_TimestampXAxisBarChartPainter oldDelegate) {
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
