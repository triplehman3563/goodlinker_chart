import 'package:flutter/material.dart';

class ChartStyle {
  /// the style about data in chart.
  final DataStyle lineStyle;

  /// style about X-Axis in chart.
  final AxisStyle xAxisStyle;

  /// style about Y-Axis in chart.
  final AxisStyle yAxisStyle;

  ChartStyle({
    DataStyle? lineStyle,
    AxisStyle? xAxisStyle,
    AxisStyle? yAxisStyle,
  })  : lineStyle = lineStyle ?? DataStyle(),
        xAxisStyle = xAxisStyle ?? AxisStyle(),
        yAxisStyle = yAxisStyle ?? AxisStyle();
}

class DataStyle {
  /// color of data lines or bars and area when it is not masked. Default to be rgb(7, 206, 63).
  final Color normalColor;

  /// color of data lines or bars and area when it is masked. Default to be rgb(239, 87, 38).
  final Color maskedColor;

  /// color of max value line. Default to be rgb(92, 176, 223).
  final Color maxValueColor;

  /// color of min value line. Default to be rgb(244, 220, 0).
  final Color minValueColor;

  /// width of data line if it's line chart. Default to be 1 dp.
  final double dataLineWidth;
  DataStyle(
      {Color? normalColor,
      Color? underMaskColor,
      Color? maxValueColor,
      Color? minValueColor,
      double? width})
      : normalColor = normalColor ?? Color.fromARGB(255, 7, 206, 63),
        maskedColor = underMaskColor ?? Color.fromARGB(255, 239, 87, 38),
        maxValueColor = maxValueColor ?? Color.fromARGB(255, 19 , 114, 167),
        minValueColor = minValueColor ?? Color.fromARGB(255, 183, 217, 235),
        dataLineWidth = width ?? 1;
}

class AxisStyle {
  /// font size use in axis.
  final double axisLabelFontSize;

  /// color of text use in axis. Default to be argb(89,0,0,0).
  final Color textColor;

  /// color of background use in axis. Default to be argb(20,0,0,0).
  final Color backgroundColor;

  /// color of border between axis and data area. Default to be argb(40,0,0,0).
  final Color axisBorderLineColor;
  AxisStyle({
    double? axisLabelFontSize,
    Color? textColor,
    Color? backgroundColor,
    Color? axisBorderLineColor,
  })  : axisLabelFontSize = axisLabelFontSize ?? 10,
        textColor = textColor ?? Color.fromARGB(89, 0, 0, 0),
        backgroundColor = backgroundColor ?? Color.fromARGB(20, 0, 0, 0),
        axisBorderLineColor =
            axisBorderLineColor ?? Color.fromARGB(40, 0, 0, 0);
}
