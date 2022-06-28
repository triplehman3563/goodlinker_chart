// ignore_for_file: file_names

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ChartRuleline extends Equatable {
  final double dy;
  final Color baselineColor;

  const ChartRuleline({required this.dy, Color? baselineColor})
      : baselineColor = baselineColor ?? Colors.red;

  @override
  List<Object?> get props => [dy, baselineColor];
}
