// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goodlinker_chart/src/usecases/ApplyPaddingUsecase.dart';

void main() {
  testWidgets('ApplyPaddingUsecase ...', (tester) async {
    const Size testCanvasSize = Size(108, 108);
    const EdgeInsets testPadding = EdgeInsets.fromLTRB(4, 2, 4, 2);
    double testXAxisHeight = 4;
    final Size result = ApplyPaddingUsecase().applyPadding(
        canvasSize: testCanvasSize,
        padding: testPadding,
        xAxisHeight: testXAxisHeight);
    expect(result, const Size(100, 100));
  });
}
