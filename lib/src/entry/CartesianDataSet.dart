import 'package:goodlinker_chart/src/entry/CartesianData.dart';

class CartesianDataSet {
  /// the position of upper masked area edge line compares to the y values in data.
  final double? upperMaskLine;

  /// the position of lower masked area edge line compares to the y values in data.
  final double? lowerMaskLine;

  /// the position of maxValue line compares to the y values in data.
  final double? maxValue;

  /// the position of minValue line compares to the y values in data.
  final double? minValue;

  /// the CartesianData displaying.
  final CartesianData data;

  CartesianDataSet({
    required this.data,
    this.upperMaskLine,
    this.lowerMaskLine,
    this.maxValue,
    this.minValue,
  });
}
