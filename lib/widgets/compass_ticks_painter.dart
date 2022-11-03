import 'dart:math';

import 'package:flutter/material.dart';

class CompassTicksPainter extends CustomPainter {
  final Paint compassTicksPaint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    final angle = 2 * pi / 360;
    final radius = size.width / 2;

    canvas.save();
    canvas.translate(radius, radius);
    for (var i = 0; i < 360; i++) {
      if (i % 15 == 0) {
        compassTicksPaint.strokeWidth = 2;
        compassTicksPaint.color = Colors.black;
        canvas.drawLine(
            Offset(0, -radius), Offset(0, -radius + 13), compassTicksPaint);
      } else {
        compassTicksPaint.strokeWidth = 1;
        compassTicksPaint.color = Colors.black;
        canvas.drawLine(
            Offset(0, -radius), Offset(0, -radius + 5), compassTicksPaint);
      }

      canvas.rotate(angle);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
