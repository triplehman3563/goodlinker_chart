// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:goodlinker_chart/entry/ChartRuleLine.dart';
import 'package:goodlinker_chart/entry/TimestampXAxisData.dart';
import 'package:goodlinker_chart/entry/TimestampXAxisDataSet.dart';
import 'package:goodlinker_chart/src/TimestampXAxisChartBase.dart';
import 'package:goodlinker_chart/src/Utils.dart';
import 'package:goodlinker_chart/src/usecases/ApplyPaddingUsecase.dart';
import 'package:goodlinker_chart/src/usecases/CalculateOffsets.dart';
import 'package:goodlinker_chart/style/BarChartStyle.dart';

class TimestampXAxisBarChart extends StatefulWidget {
  final TimestampXAxisDataSet dataSet;
  final BarChartStyle style;
  final EdgeInsets padding;
  TimestampXAxisBarChart({
    Key? key,
    required this.dataSet,
    BarChartStyle? style,
    EdgeInsets? padding,
  })  : style = style ?? BarChartStyle(),
        padding = padding ?? EdgeInsets.fromLTRB(2, 4, 2, 4),
        super(key: key);

  @override
  State<TimestampXAxisBarChart> createState() => _TimestampXAxisBarChartState();
}

class _TimestampXAxisBarChartState extends State<TimestampXAxisBarChart> {
  @override
  Widget build(BuildContext context) {
    return TimestampXAxisChartBase(
      child: CustomPaint(
        painter: _TimestampXAxisBarChartPainter(
            dataSet: widget.dataSet,
            style: widget.style,
            padding: widget.padding),
      ),
    );
  }
}

class _TimestampXAxisBarChartPainter extends CustomPainter {
  final BarChartStyle style;
  final TimestampXAxisDataSet dataSet;
  final EdgeInsets padding;

  _TimestampXAxisBarChartPainter(
      {required this.style, required this.dataSet, required this.padding});

  // limitAreaColor = limitAreaColor ?? Color.fromARGB(25, 239, 87, 38),

  late final double xAxisHeight = style.xAxisStyle.axisLabelFontSize + 2;
  late final double verticalPadding = padding.top;
  late final double horizontalPadding = padding.left;

  void _drawLastBar({required Canvas canvas, required Size size}) {
    final safeAreaLinePaint = Paint()
      ..color = style.barStyle.emphasizedNormalColor
      ..strokeWidth = 1;
    final limitAreaLinePaint = Paint()
      ..color = style.barStyle.emphasizedUnderMaskColor
      ..strokeWidth = 1;
    final barWidth = (size.width - horizontalPadding * 2) / dataSet.data.length;
    TimestampXAxisDataSet newDataSet = CalculateOffsets().calculateOffsets(
        canvasSize: size,
        dataSet: dataSet,
        padding: EdgeInsets.fromLTRB(horizontalPadding, verticalPadding,
            horizontalPadding, verticalPadding),
        xAxisHeight: xAxisHeight);

    final TimestampXAxisData lastDataPoint = newDataSet.data
        .reduce((value, element) => value.x > element.x ? value : element);
    final canvasSize = ApplyPaddingUsecase().applyPadding(
        canvasSize: size,
        padding: EdgeInsets.fromLTRB(horizontalPadding, verticalPadding,
            horizontalPadding, verticalPadding),
        xAxisHeight: xAxisHeight);
    canvas.drawRect(
        Rect.fromPoints(
            Offset(lastDataPoint.x.toDouble() - barWidth,
                canvasSize.height + verticalPadding),
            Offset(lastDataPoint.x.toDouble() + barWidth, lastDataPoint.y)),
        safeAreaLinePaint);
    final lowerBaseline = newDataSet.lowerBaseline?.dy;
    if (lowerBaseline != null) {
      if (lastDataPoint.y >= lowerBaseline) {
        canvas.drawRect(
            Rect.fromPoints(
                Offset(lastDataPoint.x.toDouble() - barWidth,
                    canvasSize.height + verticalPadding),
                Offset(lastDataPoint.x.toDouble() + barWidth, lastDataPoint.y)),
            limitAreaLinePaint);
      } else {
        canvas.drawRect(
            Rect.fromPoints(
                Offset(lastDataPoint.x.toDouble() - barWidth,
                    canvasSize.height + verticalPadding),
                Offset(lastDataPoint.x.toDouble() + barWidth, lowerBaseline)),
            limitAreaLinePaint);
      }
    }
    final upperBaseline = newDataSet.upperBaseline?.dy;

    if (upperBaseline != null) {
      if (lastDataPoint.y <= upperBaseline) {
        canvas.drawRect(
            Rect.fromPoints(
                Offset(lastDataPoint.x.toDouble() - barWidth, upperBaseline),
                Offset(lastDataPoint.x.toDouble() + barWidth, lastDataPoint.y)),
            limitAreaLinePaint);
      }
    }
  }

  void _drawBaseline({required Canvas canvas, required Size size}) {
    final limitAreaLinePaint = Paint()
      ..color = style.baseLineStyle.baselineColor;
    final limitAreaPaint = Paint()
      ..color = style.baseLineStyle.maskColor
      ..strokeWidth = style.baseLineStyle.width
      ..style = PaintingStyle.fill;
    final normalAreaPaint = Paint()..color = style.normalAreaColor;
    final Offset originPoint = _getGraphAreaOriginOffset(size: size);
    final Size drawingArea = _getGraphAreaSize(size: size);
// draw lower
    final newDataSet = CalculateOffsets().calculateOffsets(
        canvasSize: size,
        dataSet: dataSet,
        padding: EdgeInsets.fromLTRB(horizontalPadding, verticalPadding,
            horizontalPadding, verticalPadding),
        xAxisHeight: xAxisHeight);
    ChartBaseline? lowerBaseline = newDataSet.lowerBaseline;
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
    ChartBaseline? upperBaseline = newDataSet.upperBaseline;
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
    // drawSafe
    canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromPoints(
            Offset(
                0,
                newDataSet.upperBaseline?.dy ??
                    (originPoint.dy - drawingArea.height - verticalPadding)),
            Offset(
                size.width,
                newDataSet.lowerBaseline?.dy ??
                    (originPoint.dy + verticalPadding)),
          ),
          Radius.circular(10),
        ),
        normalAreaPaint);
  }

  void _drawLine({required Canvas canvas, required Size size}) {
    final safeAreaLinePaint = Paint()
      ..color = style.barStyle.normalColor
      ..strokeWidth = 2;
    final limitAreaLinePaint = Paint()
      ..color = style.barStyle.underMaskColor
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
              Offset(thisElement.x.toDouble() + barWidth * 0.5, thisElement.y)),
          safeAreaLinePaint);
      final lowerBaseline = newDataSet.lowerBaseline?.dy;
      if (lowerBaseline != null) {
        if (thisElement.y >= lowerBaseline) {
          canvas.drawRect(
              Rect.fromPoints(
                  Offset(thisElement.x.toDouble() - barWidth * 0.5,
                      canvasSize.height + verticalPadding),
                  Offset(thisElement.x.toDouble() + barWidth * 0.5,
                      thisElement.y)),
              limitAreaLinePaint);
        } else {
          canvas.drawRect(
              Rect.fromPoints(
                  Offset(thisElement.x.toDouble() - barWidth * 0.5,
                      canvasSize.height + verticalPadding),
                  Offset(thisElement.x.toDouble() + barWidth * 0.5,
                      lowerBaseline)),
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
                  Offset(thisElement.x.toDouble() + barWidth * 0.5,
                      thisElement.y)),
              limitAreaLinePaint);
        }
      }
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
    _drawLastBar(canvas: canvas, size: size);

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
