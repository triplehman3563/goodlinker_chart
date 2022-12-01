import 'package:flutter/material.dart';
import 'package:goodlinker_chart/src/style/AxisStyle.dart';
import 'package:tuple/tuple.dart';

/// the style applies on [BarChart].
class BarChartStyle {
  /// background color of the bottom of all chart, default to be grey.
  final Color backgroundColor;

  /// background color of the xAxis of chart, default to be blueGrey.
  final Color xAxisBackgroundColor;

  /// color of the entities, default to be black.
  final Color entitiesColors;

  /// style for xAxis
  final AxisStyle xAxisStyle;

  /// style for xAxis
  final AxisStyle yAxisStyle;

  /// padding between bars and border
  final EdgeInsets innerPadding;
  BarChartStyle({
    Color? backgroundColor,
    Color? xAxisBackgroundColor,
    Color? entitiesColors,
    AxisStyle? xAxisStyle,
    AxisStyle? yAxisStyle,
    EdgeInsets? innerPadding,
  })  : backgroundColor = backgroundColor ?? Colors.grey,
        xAxisBackgroundColor = xAxisBackgroundColor ?? Colors.blueGrey,
        entitiesColors = entitiesColors ?? Colors.black,
        xAxisStyle = xAxisStyle ?? AxisStyle(),
        yAxisStyle = yAxisStyle ?? AxisStyle(),
        innerPadding = innerPadding ?? EdgeInsets.all(4);
}
