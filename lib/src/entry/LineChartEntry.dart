import 'package:goodlinker_chart/src/entry/CartesianEntry.dart';

class LineChartEntry {
  final double x;
  final double? y;
  final CartesianEntry originEntry;

  LineChartEntry({
    required this.x,
    required this.y,
    required this.originEntry,
  });
}
