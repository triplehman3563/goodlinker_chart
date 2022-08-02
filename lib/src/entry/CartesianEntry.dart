class CartesianEntry {
  /// x value.
  final double? x;

  /// y value.
  final double? y;

  /// some addition information. Use it carefully.
  final dynamic data;

  CartesianEntry({
    this.x,
    this.y,
    this.data,
  });

  CartesianEntry copyWith({
    double? x,
    double? y,
    dynamic data,
  }) =>
      CartesianEntry(
        x: x ?? this.x,
        y: y ?? this.y,
        data: data ?? this.data,
      );
}
