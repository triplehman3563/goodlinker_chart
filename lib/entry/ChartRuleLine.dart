// ignore_for_file: file_names

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// The Baseline data to draw Baseline on chart.
class ChartBaseline extends Equatable {
  /// the y value of baseline.
  final double dy;

  const ChartBaseline({required this.dy, Color? baselineColor});

  @override
  List<Object?> get props => [dy];
}
