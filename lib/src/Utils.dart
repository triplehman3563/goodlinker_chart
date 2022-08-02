// ignore_for_file: file_names

extension FindIntListMax on List<int> {
  int max() =>
      reduce((value, element) => value > element ? value : element);
  int min() =>
      reduce((value, element) => value < element ? value : element);
}

extension FindDoubleListMax on List<double> {
  double max() =>
      reduce((value, element) => value > element ? value : element);
  double min() =>
      reduce((value, element) => value < element ? value : element);
}

extension DateTimeFormatpr on DateTime {
  String hourMinuteString() => minute == 0
      ? '$hour時'
      : '${hour >= 10 ? '$hour' : '0$hour'}:${minute >= 10 ? '$minute' : '0$minute'}';
}
