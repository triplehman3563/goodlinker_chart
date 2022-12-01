import 'dart:developer';

import 'package:flutter/material.dart';

class ContrastColorCalculate {
  Color determinemonochromeFontColorFromBackground(
      {required Color backgroundColor}) {
    final double bgLRV = _calLRV(backgroundColor);
    final blackHue = 33;
    final whiteHue = 85;
    final blackContrast = blackHue > bgLRV
        ? 100 * (blackHue - bgLRV) / blackHue
        : 100 * (bgLRV - blackHue) / bgLRV;
    final whiteContrast = whiteHue > bgLRV
        ? 100 * (whiteHue - bgLRV) / whiteHue
        : 100 * (bgLRV - whiteHue) / bgLRV;
    log('whiteCon: $whiteContrast');
    log('blackCon: $blackContrast');

    return whiteContrast > blackContrast ? Colors.white : Colors.black;
  }

  double _calLRV(Color backgroundColor) {
    final gray = _grayLeveling(backgroundColor);
    final double percentage = gray.green / 255 * 100;
    log('bgLRV: $percentage');
    return percentage;
  }

  Color _grayLeveling(Color color) {
    final int grayValue =
        (color.red * 0.299 + color.green * 0.587 + color.blue * 0.114).round();
    return Color.fromARGB(color.alpha, grayValue, grayValue, grayValue);
  }
}
