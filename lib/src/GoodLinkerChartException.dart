class GoodLinkerChartException implements Exception {
  final String cause;
  GoodLinkerChartException(this.cause);
  @override
  String toString() {
    return cause;
  }
}
