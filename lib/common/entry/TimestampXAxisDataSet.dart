// ignore_for_file: file_names

import 'package:equatable/equatable.dart';
import 'package:goodlinker_chart/common/entry/ChartRuleLine.dart';
import 'package:goodlinker_chart/common/entry/TimestampXAxisData.dart';

class TimestampXAxisDataSet extends Equatable {
  final List<TimestampXAxisData> data;
  final int xAxisStartPoint;
  final int xAxisEndPoint;
  final ChartRuleline? upperBaseline;
  final ChartRuleline? lowerBaseline;

  TimestampXAxisDataSet({
    required this.data,
    required this.xAxisStartPoint,
    required this.xAxisEndPoint,
    // required this.baseline,
    required this.upperBaseline,
    required this.lowerBaseline,
  });
  TimestampXAxisDataSet copyWith({
    List<TimestampXAxisData>? data,
    int? xAxisStartPoint,
    int? xAxisEndPoint,
    ChartRuleline? upperBaseline,
    ChartRuleline? lowerBaseline,
  }) =>
      TimestampXAxisDataSet(
        data: data ?? this.data,
        xAxisStartPoint: xAxisStartPoint ?? this.xAxisStartPoint,
        xAxisEndPoint: xAxisEndPoint ?? this.xAxisEndPoint,
        upperBaseline: upperBaseline ?? this.upperBaseline,
        lowerBaseline: lowerBaseline ?? this.lowerBaseline,
      );
  late final List<int> wholeXAxisData = data.map((e) => e.x).toList();
  late final List<double> wholeYAxisData = data.map((e) => e.y).toList()
    ..addAll([upperBaseline?.dy, lowerBaseline?.dy].whereType<double>());

  @override
  List<Object?> get props => [
        data,
        xAxisStartPoint,
        xAxisEndPoint,
        upperBaseline,
        lowerBaseline,
      ];
}
