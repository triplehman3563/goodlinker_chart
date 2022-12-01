class NewData<T> {
  /// A integer value, represent x axis position.
  final int x;

  /// A double value, pass NaN(Not a Number) for data absent.
  final double y;

  /// A data with custom type coming with the this data point;
  final T? data;

  NewData({
    required this.x,
    required this.y,
    this.data,
  });
}
