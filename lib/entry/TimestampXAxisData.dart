// ignore_for_file: file_names

import 'package:equatable/equatable.dart';

/// should be a timestampSeconds
class TimestampXAxisData extends Equatable {
  /// A timestampSeconds describing the x-axis position the data should be located.
  final int x;

  /// A value describing the y-axis position the data should be located.
  final double y;

  TimestampXAxisData({required this.x, required this.y});

  @override
  List<Object?> get props => [x, y];
}
