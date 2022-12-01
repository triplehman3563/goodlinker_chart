import 'package:flutter/material.dart';
import 'package:goodlinker_chart/src/GoodLinkerChartException.dart';

class AxisStyle {
  final double fontSize;
  final double lineHeightFactor;
  final Color fontColor;

  AxisStyle({
    double? fontSize,
    double? lineHeightFactor,
    Color? fontColor,
  })  : assert((fontSize != null ? fontSize.isNaN == false : true) ||
            (throw GoodLinkerChartException('fontSize shouldn\'t be a NaN.'))),
        fontSize = fontSize ?? 10,
        lineHeightFactor = lineHeightFactor ?? 1.2,
        fontColor = fontColor ?? Colors.black;
}
