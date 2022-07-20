import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:goodlinker_chart/entry/ChartRuleLine.dart';
import 'package:goodlinker_chart/entry/TimestampXAxisDataSet.dart';
import 'package:goodlinker_chart/src/TimestampXAxisChartBase.dart';
import 'package:goodlinker_chart/src/Utils.dart';
import 'package:goodlinker_chart/src/usecases/ApplyPaddingUsecase.dart';
import 'package:goodlinker_chart/style/LineChartStyle.dart';

class LineChart extends StatefulWidget {
  LineChart({
    required this.dataSet,
    this.xAxisFormatter,
    Key? key,
    double? axisLabelFontSize,
    LineChartStyle? style,
    EdgeInsets? padding,
    bool? enableXScale,
    bool? enableXScroll,
    bool? debug,
  })  : padding = padding ?? EdgeInsets.fromLTRB(2, 4, 2, 4),
        style = style ?? LineChartStyle(),
        enableXZoom = enableXScale ?? true,
        enableXScroll = enableXScroll ?? true,
        debug = debug ?? false,
        super(key: key);
  final TimestampXAxisDataSet dataSet;
  final LineChartStyle style;
  final EdgeInsets padding;
  final bool enableXZoom;
  final bool enableXScroll;
  final String Function(double value)? xAxisFormatter;
  final bool debug;

  @override
  State<LineChart> createState() => _LineChartState();
}

class _LineChartState extends State<LineChart>
    with SingleTickerProviderStateMixin {
  late AnimationController ctrl;

  late double prevScale;
  double scale = 1;

  late Offset _startingFocalPoint;

  late Offset _previousOffset;
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
                  painter: LineChartPainter(
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
      _startingFocalPoint = details.focalPoint;
      _previousOffset = _diagramOffset;
      prevScale = scale;
      ctrl.stop();
      log('_startingFocalPoint: $_startingFocalPoint');
    });
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      scale = (prevScale * details.horizontalScale).clamp(1, 10);
      ctrl.value = details.focalPointDelta.dx;
      log('(details.focalPoint - _startingFocalPoint): ${(details.focalPoint - _startingFocalPoint)}');
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

class LineChartPainter extends CustomPainter {
  final LineChartStyle style;
  final TimestampXAxisDataSet dataSet;
  final EdgeInsets padding;
  final bool debug;
  LineChartPainter({
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
  @override
  bool shouldRepaint(LineChartPainter oldDelegate) {
    return scale != oldDelegate.scale ||
        diagramOffset != oldDelegate.diagramOffset ||
        dataSet.data.length != oldDelegate.dataSet.data.length;
  }

  @override
  void paint(Canvas canvas, Size size) {
    List<Offset> lineData = _calculateLineOffsets(size: size);
    _drawLine(canvas: canvas, size: size, lineData: lineData);
    _drawBaseline(canvas: canvas, size: size);
    _drawAimLine(canvas: canvas, size: size);
    _drawLastDataCircle(canvas: canvas, size: size);
    if (debug) _drawDebugInfo(canvas: canvas, size: size);
  }

  void _drawLine({
    required Canvas canvas,
    required Size size,
    required List<Offset> lineData,
  }) {
    final safeAreaLinePaint = Paint()
      ..color = style.lineStyle.normalColor
      ..strokeWidth = style.lineStyle.width;
    final limitAreaLinePaint = Paint()
      ..color = style.lineStyle.underMaskColor
      ..strokeWidth = style.lineStyle.width;
    double widthRemain = 0;
    lineData.asMap().forEach((index, data) {
      if (index != 0) {
        final pointWidth = data.dx - lineData[index - 1].dx;
        if (lineData[index - 1] >=
                Offset.zero.translate(padding.left, padding.top) &&
            data <=
                Offset.zero.translate(
                    size.width - padding.right, size.height - padding.bottom)) {
          final Offset srcOffset = lineData[index - 1];
          final Offset tarOffset = data;

          try {
            canvas.drawLine(srcOffset, tarOffset, safeAreaLinePaint);
          } catch (err, s) {
            print(err);
            print(s);
          }
          ChartBaseline? _upperBaseline = _calUpperBaseline(size: size);
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
          ChartBaseline? _lowerBaseline = _calLowerBaseline(size: size);
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

          // draw x-axis
          if (widthRemain >= 0) {
            final thisDraw = _drawXAxisLabel(
              canvas: canvas,
              size: size,
              index: index,
              src: lineData[index - 1],
              tar: data,
              xData: dataSet.data[index - 1].x.toDouble(),
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

    ChartBaseline? _lowerBaseline = _calLowerBaseline(size: size);
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
    ChartBaseline? _upperBaseline = _calUpperBaseline(size: size);
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
                _upperBaseline?.dy ??
                    (_originPoint.dy - _drawingArea.height - verticalPadding)),
            Offset(size.width,
                _lowerBaseline?.dy ?? (_originPoint.dy + verticalPadding)),
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
    List<Offset> lineData = _calculateLineOffsets(size: size);

    final lastDataPoint = lineData
        .reduce((value, element) => value.dx > element.dx ? value : element);
    var circlePaint = safeAreaLinePaint;
    final lowerBaseline = _calLowerBaseline(size: size);
    if (lowerBaseline != null) {
      if (lastDataPoint.dy >= lowerBaseline.dy) {
        circlePaint = limitAreaLinePaint;
      }
    }
    final upperBaseline = _calUpperBaseline(size: size);

    if (upperBaseline != null) {
      if (lastDataPoint.dy <= upperBaseline.dy) {
        circlePaint = limitAreaLinePaint;
      }
    }

    canvas.drawCircle(Offset(lastDataPoint.dx.toDouble(), lastDataPoint.dy),
        style.circleStyle.size, circlePaint);

    Paint aimLinePaint = Paint()
      ..color = Color.fromARGB(20, 33, 33, 33)
      ..strokeWidth = 2;

    canvas.drawLine(
        Offset(lastDataPoint.dx.toDouble(), size.height - xAxisHeight),
        Offset(lastDataPoint.dx.toDouble(), 0),
        aimLinePaint);
  }

  _LastLabel _drawXAxisLabel({
    required Canvas canvas,
    required Size size,
    required int index,
    required Offset src,
    required Offset tar,
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

  double _calZoomLevelX({required Size size}) {
    final thisScale = scale;
    if (thisScale != null) {
      return math.pow(2, (thisScale / size.width)).toDouble();
    } else {
      return 1;
    }
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

    final _upperBaseline = upperBaseline != null
        ? ChartBaseline(
            dy: canvasSize.height +
                padding.top +
                (upperBaseline.dy - yMin) * -yRatio,
          )
        : null;
    return _upperBaseline;
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

    final _lowerBaseline = lowerBaseline != null
        ? ChartBaseline(
            dy: canvasSize.height +
                padding.top +
                (lowerBaseline.dy - yMin) * -yRatio,
          )
        : null;
    return _lowerBaseline;
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
    final zoomLevelX = _calZoomLevelX(size: size);

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
