// ignore_for_file: file_names

import 'package:flutter/material.dart';

class ApplyPaddingUsecase {
  Size applyPadding({
    required Size canvasSize,
    required EdgeInsets padding,
    required double xAxisHeight,
  }) {
    return Size(canvasSize.width - padding.horizontal,
        canvasSize.height - padding.vertical - xAxisHeight);
  }
}
