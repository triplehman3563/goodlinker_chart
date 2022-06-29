import 'package:flutter/material.dart';
import 'package:goodlinker_chart/style/AxisStyle.dart';
import 'package:goodlinker_chart/style/BaseLineStyle.dart';

class LineChartStyle {
  final LineStyle lineStyle;
  final CircleStyle circleStyle;
  final BaseLineStyle baseLineStyle;
  final AxisStyle xAxisStyle;
  final Color normalAreaColor;
  LineChartStyle({
    LineStyle? lineStyle,
    CircleStyle? circleStyle,
    AxisStyle? xAxisStyle,
    BaseLineStyle? baseLineStyle,
    Color? normalAreaColor,
  })  : lineStyle = lineStyle ?? LineStyle(),
        circleStyle = circleStyle ?? CircleStyle(),
        xAxisStyle = xAxisStyle ?? AxisStyle(),
        baseLineStyle = baseLineStyle ?? BaseLineStyle(),
        normalAreaColor = normalAreaColor ?? Color.fromARGB(25, 7, 206, 63);
}

class LineStyle {
  final Color normalColor;
  final Color underMaskColor;
  final double width;

  LineStyle({Color? normalColor, Color? underMaskColor, double? width})
      : normalColor = normalColor ?? Colors.green,
        underMaskColor = underMaskColor ?? Colors.red,
        width = width ?? 2;
}

class CircleStyle {
  final double size;
  final bool followLineColor;
  final Color? normalColor;
  final Color? underMaskColor;
  CircleStyle({
    double? size,
    bool? followLineColor,
    this.normalColor,
    this.underMaskColor,
  })  : assert(followLineColor == true ? (normalColor != null) : true,
            'color should not be null if followLineColor false.'),
        assert(followLineColor == true ? (underMaskColor != null) : true,
            'underMaskColor should not be null if followLineColor false.'),
        size = size ?? 4,
        followLineColor = followLineColor ?? true;
}
