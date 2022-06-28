// ignore_for_file: file_names

import 'package:flutter/material.dart';

class TimestampXAxisChartBase extends StatefulWidget {
  final double axisLabelFontSize;

  const TimestampXAxisChartBase({
    Key? key,
    required this.child,
    double? axisLabelFontSize,
  })  : axisLabelFontSize = axisLabelFontSize ?? 14,
        super(key: key);
  final Widget child;

  @override
  State<TimestampXAxisChartBase> createState() =>
      _TimestampXAxisChartBaseState();
}

class _TimestampXAxisChartBaseState extends State<TimestampXAxisChartBase> {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TimestampXAxisChartBasePaint(),
      child: widget.child,
    );
  }
}

class _TimestampXAxisChartBasePaint extends CustomPainter {
  final double axisLabelFontSize;
  _TimestampXAxisChartBasePaint({
    double? axisLabelFontSize,
  }) : axisLabelFontSize = axisLabelFontSize ?? 14;
  late final double xAxisHeight = axisLabelFontSize + 2;
  late final double verticalPadding = 4;
  late final double horizontalPadding = 2;

  void _drawOutterBox({required Canvas canvas, required Size size}) {
    final boxPaint = Paint()
      ..color = Color.fromARGB(20, 33, 33, 33)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromPoints(Offset(0, 0), Offset(size.width, size.height)),
          Radius.circular(10),
        ),
        boxPaint);
  }

  void _drawDivider({required Canvas canvas, required Size size}) {
    final boxPaint = Paint()
      ..color = Color.fromARGB(20, 33, 33, 33)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, size.height - xAxisHeight),
        Offset(size.width, size.height - xAxisHeight), boxPaint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawOutterBox(canvas: canvas, size: size);
    _drawDivider(canvas: canvas, size: size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
