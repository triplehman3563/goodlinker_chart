import 'package:flutter/material.dart';

class BaseLineStyle {
  final Color baselineColor;
  final Color maskColor;
  final double width;

  BaseLineStyle({Color? baselineColor, Color? maskColor, double? width})
      : baselineColor = baselineColor ?? Colors.red,
        maskColor = maskColor ?? Color.fromARGB(25, 239, 87, 38),
        width = width ?? 2;
}
