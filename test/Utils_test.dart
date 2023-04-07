// ignore_for_file: file_names

import 'package:flutter_test/flutter_test.dart';
import 'package:goodlinker_chart/src/Utils.dart';

void main() {
  testWidgets('Utils ...', (tester) async {
    final List<double> doubleTestData = [0, 1, 2, 3, 4, double.nan];
    final List<int> intTestData = [0, 1, 2, 3, 4];
    expect(doubleTestData.max(), 4);
    expect(doubleTestData.min(), 0);
    expect(intTestData.max(), 4);
    expect(intTestData.min(), 0);
    final DateTime testDateTime1 = DateTime(2022, 1, 1, 13, 12, 59);
    expect(testDateTime1.hourMinuteString(), '13:12');
    final DateTime testDateTime2 = DateTime(2022, 1, 1, 9, 8, 1);
    expect(testDateTime2.hourMinuteString(), '09:08');
    final DateTime testDateTime3 = DateTime(2022, 1, 1, 9, 0, 0);
    expect(testDateTime3.hourMinuteString(), '9時');
  });
}
