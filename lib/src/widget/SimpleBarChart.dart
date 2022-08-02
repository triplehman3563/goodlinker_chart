import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:goodlinker_chart/src/TimestampXAxisChartBase.dart';
import 'package:goodlinker_chart/src/Utils.dart';
import 'package:goodlinker_chart/src/entry/ChartRuleLine.dart';
import 'package:goodlinker_chart/src/entry/TimestampXAxisDataSet.dart';
import 'package:goodlinker_chart/src/style/BarChartStyle.dart';
import 'package:goodlinker_chart/src/usecases/ApplyPaddingUsecase.dart';

/// A simple bar-chart which is not scrollable or scalible.
class SimpleBarChart extends StatefulWidget {
  SimpleBarChart({
    required this.dataSet,
    this.xAxisFormatter,
    Key? key,
    double? axisLabelFontSize,
    BarChartStyle? style,
    EdgeInsets? padding,
    bool? enableXScale,
    bool? enableXScroll,
    bool? debug,
  })  : padding = padding ?? EdgeInsets.fromLTRB(2, 4, 2, 4),
        style = style ?? BarChartStyle(),
        enableXZoom = enableXScale ?? true,
        enableXScroll = enableXScroll ?? true,
        debug = debug ?? false,
        super(key: key);

  final TimestampXAxisDataSet dataSet;
  final BarChartStyle style;
  final EdgeInsets padding;
  final bool enableXZoom;
  final bool enableXScroll;
  final String Function(double value)? xAxisFormatter;
  final bool debug;

  @override
  State<SimpleBarChart> createState() => _SimpleBarChartState();
}

class _SimpleBarChartState extends State<SimpleBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController ctrl;
  late double prevScale;
  double scale = 1;
  late Offset startingFocalPoint;
  late Offset previousOffset;
  Offset _diagramOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    ctrl = AnimationController.unbounded(vsync: this);
    ctrl.addListener(() {});
    ctrl.addStatusListener((status) {
      if (status.name == AnimationStatus.completed.name) {
        ctrl.value = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onDoubleTap: () {
            setState(() {
              _diagramOffset = Offset.zero;
              scale = 1;
            });
          },
          onTapDown: (TapDownDetails details) {
            ctrl.stop();
            ctrl.value = 0;
          },
          onScaleStart: widget.enableXZoom ? _onScaleStart : null,
          onScaleUpdate: widget.enableXZoom ? _onScaleUpdate : null,
          onScaleEnd: widget.enableXZoom ? _onScaleEnd : null,
          child: AnimatedBuilder(
            animation: ctrl,
            builder: (context, w) {
              final double rightDragDis = 100;
              final double leftDragDis =
                  100 + (scale - 1) * constraints.maxWidth;
              if (_diagramOffset.translate(ctrl.value, 0).dx < -leftDragDis) {
                _diagramOffset = Offset(-leftDragDis, _diagramOffset.dy);
                ctrl.stop();
                ctrl.value = 0;
              }
              if (_diagramOffset.translate(ctrl.value, 0).dx > rightDragDis) {
                _diagramOffset = Offset(rightDragDis, _diagramOffset.dy);
                ctrl.stop();
                ctrl.value = 0;
              }

              if (_diagramOffset.translate(ctrl.value, 0).dx > -leftDragDis &&
                  _diagramOffset.translate(ctrl.value, 0).dx < rightDragDis) {
                _diagramOffset = _diagramOffset.translate(ctrl.value, 0);
              }

              return TimestampXAxisChartBase(
                child: CustomPaint(
                  painter: BarChartPainter(
                    dataSet: widget.dataSet,
                    xAxisFormatter: widget.xAxisFormatter,
                    style: widget.style,
                    padding: widget.padding,
                    scale: scale,
                    diagramOffset: _diagramOffset,
                    debug: widget.debug,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _onScaleStart(ScaleStartDetails details) {
    setState(() {
      startingFocalPoint = details.focalPoint;
      previousOffset = _diagramOffset;
      prevScale = scale;
      ctrl.stop();
    });
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      scale = (prevScale * details.horizontalScale).clamp(1, 10);
      ctrl.value = details.focalPointDelta.dx;
    });
  }

  void _onScaleEnd(ScaleEndDetails details) {
    setState(() {
      // dragLocalPosition = null;
      Simulation;
      ctrl.animateWith(FrictionSimulation(
          0.001, // <- the bigger this value, the less friction is applied
          ctrl.value,
          details.velocity.pixelsPerSecond.dx / 20 // <- Velocity of inertia
          ));
    });
  }
}

class BarChartPainter extends CustomPainter {
  final BarChartStyle style;
  final TimestampXAxisDataSet dataSet;
  final EdgeInsets padding;
  BarChartPainter({
    required this.style,
    required this.dataSet,
    required this.padding,
    required this.scale,
    required this.debug,
    this.diagramOffset,
    this.xAxisFormatter,
  });
  late final double xAxisHeight = style.xAxisStyle.axisLabelFontSize + 2;
  late final double verticalPadding = padding.top;
  late final double horizontalPadding = padding.left;
  final Offset? diagramOffset;
  final double scale;
  final String Function(double value)? xAxisFormatter;
  final bool debug;

  @override
  bool shouldRepaint(BarChartPainter oldDelegate) {
    return scale != oldDelegate.scale ||
        diagramOffset != oldDelegate.diagramOffset ||
        dataSet.data.length != oldDelegate.dataSet.data.length;
  }

  @override
  void paint(Canvas canvas, Size size) {
    List<Offset> lineData = _calculateLineOffsets(size: size);
    _drawBar(canvas: canvas, size: size, lineData: lineData);
    _drawBaseline(canvas: canvas, size: size);
    _drawAimLine(canvas: canvas, size: size);
    if (debug) _drawDebugInfo(canvas: canvas, size: size);
  }

  void _drawBar({
    required Canvas canvas,
    required Size size,
    required List<Offset> lineData,
  }) {
    final safeAreaLinePaint = Paint()..color = style.barStyle.normalColor;

    final limitAreaLinePaint = Paint()..color = style.barStyle.underMaskColor;

    final barWidth = (size.width - horizontalPadding * 2) / lineData.length;
    final canvasSize = ApplyPaddingUsecase().applyPadding(
        canvasSize: size,
        padding: EdgeInsets.fromLTRB(horizontalPadding, verticalPadding,
            horizontalPadding, verticalPadding),
        xAxisHeight: xAxisHeight);
    double widthRemain = 0;

    lineData.asMap().forEach((index, data) {
      if (data >= Offset.zero.translate(padding.left, padding.top) &&
          data <=
              Offset.zero.translate(
                  size.width - padding.right, size.height - padding.bottom)) {
        final Offset tarOffset = data;

        try {
          canvas.drawRect(
              Rect.fromPoints(
                  Offset(tarOffset.dx.toDouble() - barWidth * 0.5,
                      canvasSize.height + verticalPadding),
                  Offset(tarOffset.dx.toDouble() + barWidth * 0.5, data.dy)),
              safeAreaLinePaint);
        } catch (err) {
          rethrow;
        }
        ChartBaseline? thisUpperBaseline = _calUpperBaseline(size: size);
        if (thisUpperBaseline != null) {
          final topLine = thisUpperBaseline.dy;

          if (tarOffset.dy <= topLine) {
            canvas.drawRect(
                Rect.fromPoints(
                    Offset(tarOffset.dx.toDouble() - barWidth * 0.5, topLine),
                    Offset(tarOffset.dx.toDouble() + barWidth * 0.5,
                        tarOffset.dy)),
                limitAreaLinePaint);
          }
        }
        ChartBaseline? thisLowerBaseline = _calLowerBaseline(size: size);
        if (thisLowerBaseline != null) {
          final bottomLine = thisLowerBaseline.dy;

          if (tarOffset.dy >= bottomLine) {
            canvas.drawRect(
                Rect.fromPoints(
                    Offset(tarOffset.dx.toDouble() - barWidth * 0.5,
                        canvasSize.height + verticalPadding),
                    Offset(
                        tarOffset.dx.toDouble() + barWidth * 0.5, bottomLine)),
                limitAreaLinePaint);
          } else {
            canvas.drawRect(
                Rect.fromPoints(
                    Offset(tarOffset.dx.toDouble() - barWidth * 0.5,
                        canvasSize.height + verticalPadding),
                    Offset(
                        tarOffset.dx.toDouble() + barWidth * 0.5, bottomLine)),
                limitAreaLinePaint);
          }
        }

        // draw x-axis
        if (widthRemain >= 0) {
          final thisDraw = _drawXAxisLabel(
            canvas: canvas,
            size: size,
            index: index,
            src: data,
            xData: dataSet.data[index].x.toDouble(),
          );

          if ((barWidth - thisDraw.width) > 0) {
          } else {
            widthRemain = barWidth - thisDraw.width;
          }
        } else {
          widthRemain = widthRemain + barWidth;
        }
      }
    });
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

    ChartBaseline? thisLowerBaseline = _calLowerBaseline(size: size);
    if (thisLowerBaseline != null) {
      final double lowerRuleLineY = thisLowerBaseline.dy;
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
    ChartBaseline? thisUpperBaseline = _calUpperBaseline(size: size);
    if (thisUpperBaseline != null) {
      final double upperRuleLineY = thisUpperBaseline.dy;
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
                thisUpperBaseline?.dy ??
                    (originPoint.dy - drawingArea.height - verticalPadding)),
            Offset(size.width,
                thisLowerBaseline?.dy ?? (originPoint.dy + verticalPadding)),
          ),
          Radius.circular(10),
        ),
        normalAreaPaint);
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

  _LastLabel _drawXAxisLabel({
    required Canvas canvas,
    required Size size,
    required int index,
    required Offset src,
    required double xData,
  }) {
    final xAxisHeight = style.xAxisStyle.axisLabelFontSize + 2;
    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: style.xAxisStyle.axisLabelFontSize,
    );
    final thisXAxisFormatter = xAxisFormatter;
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

  void _drawDebugInfo({required Canvas canvas, required Size size}) {
    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: style.xAxisStyle.axisLabelFontSize,
    );

    final TextSpan beginTextSpan = TextSpan(
      text: 'drag: ${diagramOffset?.dx ?? 0} \nscale: $scale',
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
      Offset(0 + padding.left, 0),
    );
    // ---------
  }

  ChartBaseline? _calUpperBaseline({required Size size}) {
    final canvasSize = ApplyPaddingUsecase().applyPadding(
      canvasSize: size,
      padding: padding,
      xAxisHeight: style.xAxisStyle.axisLabelFontSize + 2,
    );
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
    final yMax = yDataSets.max();
    final yMin = yDataSets.min();
    final yRange = yMax - yMin;
    final yRatio = yRange == 0 ? 1.0 : canvasSize.height / yRange;

    final thisUpperBaseline = upperBaseline != null
        ? ChartBaseline(
            dy: canvasSize.height +
                padding.top +
                (upperBaseline.dy - yMin) * -yRatio,
          )
        : null;
    return thisUpperBaseline;
  }

  ChartBaseline? _calLowerBaseline({required Size size}) {
    final canvasSize = ApplyPaddingUsecase().applyPadding(
      canvasSize: size,
      padding: padding,
      xAxisHeight: style.xAxisStyle.axisLabelFontSize + 2,
    );
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
    final yMax = yDataSets.max();
    final yMin = yDataSets.min();
    final yRange = yMax - yMin;
    final yRatio = yRange == 0 ? 1.0 : canvasSize.height / yRange;

    final thisLowerBaseline = lowerBaseline != null
        ? ChartBaseline(
            dy: canvasSize.height +
                padding.top +
                (lowerBaseline.dy - yMin) * -yRatio,
          )
        : null;
    return thisLowerBaseline;
  }

  List<Offset> _calculateLineOffsets({required Size size}) {
    final canvasSize = ApplyPaddingUsecase().applyPadding(
      canvasSize: size,
      padding: padding,
      xAxisHeight: style.xAxisStyle.axisLabelFontSize + 2,
    );
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

    return offsets.map((e) {
      final result = e
          .translate(-dataSet.xAxisStartPoint.toDouble(), -yMin)
          .scale(xRatio * scale, -yRatio)
          .translate(diagramOffset?.dx ?? 0, 0) // scale offset
          .translate(padding.left, canvasSize.height + padding.top);
      return result;
    }).toList();
  }

  Size _getGraphAreaSize({required Size size}) => Size(
      size.width - 2 * horizontalPadding,
      size.height - 2 * verticalPadding - xAxisHeight);

  Offset _getGraphAreaOriginOffset({required Size size}) => Offset(
        0 + horizontalPadding,
        0 + size.height - verticalPadding - xAxisHeight,
      );
}

class _LastLabel {
  final double width;
  final Offset offset;
  _LastLabel({
    required this.width,
    required this.offset,
  });
}
