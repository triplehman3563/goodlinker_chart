import 'package:flutter/material.dart';
import 'package:goodlinker_chart/src/style/ChartStyle.dart';

import 'package:goodlinker_chart/src/style/BaseLineStyle.dart';

class BarChartStyle {
  final AxisStyle xAxisStyle;
  final BaseLineStyle baseLineStyle;
  final BarStyle barStyle;
  final Color normalAreaColor;

  BarChartStyle(
      {AxisStyle? xAxisStyle,
      BaseLineStyle? baseLineStyle,
      Color? normalAreaColor,
      BarStyle? style})
      : xAxisStyle = xAxisStyle ?? AxisStyle(),
        baseLineStyle = baseLineStyle ?? BaseLineStyle(),
        normalAreaColor = normalAreaColor ?? Color.fromARGB(25, 7, 206, 63),
        barStyle = style ?? BarStyle();
}

class BarStyle {
  final Color normalColor;
  final Color underMaskColor;
  final Color emphasizedNormalColor;
  final Color emphasizedUnderMaskColor;

  BarStyle({
    Color? normalColor,
    Color? underMaskColor,
    double? width,
    Color? emphasizedNormalColor,
    Color? emphasizedUnderMaskColor,
  })  : normalColor = normalColor ?? Colors.green,
        underMaskColor = underMaskColor ?? Colors.red,
        emphasizedNormalColor = emphasizedNormalColor ?? Colors.green,
        emphasizedUnderMaskColor = emphasizedUnderMaskColor ?? Colors.red;
}
