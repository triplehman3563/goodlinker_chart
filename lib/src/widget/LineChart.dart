import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:goodlinker_chart/src/entry/CartesianDataSet.dart';
import 'package:goodlinker_chart/src/entry/LineChartEntry.dart';
import 'package:goodlinker_chart/src/style/ChartStyle.dart';
import 'package:goodlinker_chart/src/widget/painter/BackgroundFramePainter.dart';
import 'package:goodlinker_chart/src/widget/painter/LinePainter.dart';

class LineChart extends StatefulWidget {
  /// style which apply to chart.
  final ChartStyle style;

  /// DataSet display in chart.
  final CartesianDataSet cartesianDataSet;

  /// how many data do you want to display in one chart width. Default all datas.
  final int defalutDisplayRange;

  /// index of the data display in the middle of the chart. Default to be the middle of all datas.
  final int defaultMiddleDisplayIndex;

  /// whether the chart is scalible or scrollable. Default to be true.
  final bool scrollable;

  /// Formater of the xAxis Label. Default to be displaying the raw x data.
  final String Function(double value)? xAxisFormatter;

  /// Formater of the xAxis Label. Default to be displaying the raw y data.
  final String Function(double value)? yAxisFormatter;

  /// Padding between dataline and chart edge. Default ot be EdgeInsets.fromLTRB(2, 4, 2, 4).
  final EdgeInsets padding;

  /// Callback with the selected data info.
  final void Function(LineChartEntry entry, int selectIndex)
      dataSelectionCallback;
  LineChart({
    Key? key,
    required this.cartesianDataSet,
    required this.dataSelectionCallback,
    this.xAxisFormatter,
    this.yAxisFormatter,
    ChartStyle? style,
    EdgeInsets? padding,
    int? defaultMiddleDisplayIndex,
    int? defalutDisplayRange,
    bool? scrollable,
  })  : style = style ?? ChartStyle(),
        padding = padding ?? EdgeInsets.fromLTRB(2, 4, 2, 4),
        defaultMiddleDisplayIndex = defaultMiddleDisplayIndex ??
            (cartesianDataSet.data.entities.length / 2).floor(),
        defalutDisplayRange =
            defalutDisplayRange ?? cartesianDataSet.data.entities.length,
        scrollable = scrollable ?? true,
        assert(
            (defaultMiddleDisplayIndex ?? 0) <
                cartesianDataSet.data.entities.length,
            ''),
        assert((defalutDisplayRange ?? cartesianDataSet.data.entities.length) <=
            cartesianDataSet.data.entities.length),
        super(key: key);

  @override
  State<LineChart> createState() => _LineChartState();
}

class _LineChartState extends State<LineChart>
    with SingleTickerProviderStateMixin {
  late int currentMiddleDisplayIndex;
  late int currentDisplayRange;
  late bool dataFeedbackMode = false;
  int? dataSelectIndex;

  Offset? lastTapLocation;
  late AnimationController ctrl;
  late double prevScale;
  double scale = 1;
  late Offset startingFocalPoint;
  late Offset previousOffset;
  Offset diagramOffset = Offset.zero;
  late int maxIndex;
  @override
  void initState() {
    super.initState();
    currentMiddleDisplayIndex = widget.defaultMiddleDisplayIndex;
    currentDisplayRange = widget.defalutDisplayRange;
    maxIndex = widget.cartesianDataSet.data.entities.length;
    ctrl = AnimationController.unbounded(vsync: this);
    ctrl.addStatusListener((status) {
      if (status.name == AnimationStatus.completed.name) {
        ctrl.value = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      onTapDown: _onTapDown,
      onDoubleTap: _onDoubleTap,
      onScaleStart: _onScaleStart,
      onScaleUpdate: _onScaleUpdate,
      onScaleEnd: _onScaleEnd,
      child: AnimatedBuilder(
        animation: ctrl,
        builder: (context, child) {
          currentMiddleDisplayIndex = (currentMiddleDisplayIndex - ctrl.value)
              .round()
              .clamp(0, maxIndex - 1);
          return CustomPaint(
            painter: BackgroundFramePainter(),
            child: CustomPaint(
              painter: LinePainter(
                  style: widget.style,
                  data: widget.cartesianDataSet.data,
                  padding: widget.padding,
                  upperLine: widget.cartesianDataSet.upperMaskLine,
                  lowerline: widget.cartesianDataSet.lowerMaskLine,
                  minLine: widget.cartesianDataSet.minValue,
                  maxLine: widget.cartesianDataSet.maxValue,
                  currentMiddleDisplayIndex: currentMiddleDisplayIndex,
                  currentDisplayRange: currentDisplayRange,
                  dataFeedbackMode: dataFeedbackMode,
                  lastTapLocation: lastTapLocation,
                  xAxisFormatter: widget.xAxisFormatter,
                  yAxisFormatter: widget.yAxisFormatter,
                  dataSelectionCallback: (entry, selectIndex) {
                    widget.dataSelectionCallback(entry, selectIndex);
                  }),
            ),
          );
        },
      ),
    );
  }

  void _toogleDataFeedbackMode() {
    dataFeedbackMode = !dataFeedbackMode;
  }

  bool _determineDataFeedbackMode() {
    if (!widget.scrollable) {
      // always on if default not scrollable
      return true;
    }
    if (widget.scrollable) {
      // always on if default not scrollable
      return dataFeedbackMode;
    }
    return false;
  }

  void _onTap() {
    setState(() {
      _toogleDataFeedbackMode();
    });
  }

  void _onTapDown(TapDownDetails details) {
    ctrl.stop();
    setState(() {
      if (!_determineDataFeedbackMode()) {
        lastTapLocation = details.localPosition;
      }
    });
  }

  void _onDoubleTap() {
    setState(() {
      currentMiddleDisplayIndex = widget.defaultMiddleDisplayIndex;
      currentDisplayRange = widget.defalutDisplayRange;
      dataFeedbackMode = false;
      scale = 1;
    });
  }

  void _onScaleStart(ScaleStartDetails details) {
    if (widget.scrollable) {
      if (!_determineDataFeedbackMode()) {
        setState(() {
          startingFocalPoint = details.focalPoint;
          previousOffset = diagramOffset;
          prevScale = scale;
          ctrl.stop();
        });
      }
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (widget.scrollable) {
      if (!_determineDataFeedbackMode()) {
        setState(() {
          scale = (prevScale * details.horizontalScale).clamp(1, 10);
          currentDisplayRange = (widget.defalutDisplayRange / scale).round();
          ctrl.value = details.focalPointDelta.dx;
          currentMiddleDisplayIndex = (currentMiddleDisplayIndex - ctrl.value)
              .round()
              .clamp(0, maxIndex - 1);
        });
      } else {
        setState(() {
          lastTapLocation =
              lastTapLocation?.translate(details.focalPointDelta.dx, 0);
        });
      }
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {
    setState(() {
      // dragLocalPosition = null;
      if (widget.scrollable) {
        if (!_determineDataFeedbackMode()) {
          ctrl.animateWith(FrictionSimulation(
              0.001, // <- the bigger this value, the less friction is applied
              ctrl.value,
              details.velocity.pixelsPerSecond.dx / 20 // <- Velocity of inertia
              ));
        }
      }
    });
  }
}
