// ignore_for_file: file_names

import 'package:flutter_test/flutter_test.dart';
import 'package:goodlinker_chart/usecases/CalculateOffsets.dart';

import '../TestData.dart';

void main() {
  testWidgets('CalculateOffsets ...', (tester) async {
    final result = CalculateOffsets().calculateOffsets(
        canvasSize: TestData.testCanvasSize,
        dataSet: TestData.testDataSet,
        padding: TestData.testPadding,
        xAxisHeight: TestData.xAxisHeightTest);
    expect(result, TestData.expectDataSet);
  });
}
