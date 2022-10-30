import 'dart:math';
import 'package:flutter/material.dart';

class CompassLettersPainter extends CustomPainter {
  getLetter(int i) {
    switch (i) {
      case 0:
        return 'N';
      case 45:
        return 'NE';
      case 90:
        return 'E';
      case 135:
        return 'SE';
      case 180:
        return 'S';
      case 225:
        return 'SW';
      case 270:
        return 'W';
      case 315:
        return 'NW';
      default:
        return '';
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final angle = 2 * pi / 360;
    final radius = size.width / 2;

    canvas.save();
    canvas.translate(radius, radius);

    for (var i = 0; i < 360; i++) {
      if (i % 45 == 0) {
        canvas.save();
        canvas.translate(0, -radius + 15);
        final textPainter = TextPainter(
          text: TextSpan(
            text: getLetter(i),
            style: TextStyle(
              color: getLetter(i) == 'N' ? Color(0xffF10D0D) : Colors.black,
              fontSize: i % 90 == 0 ? 22 : 14,
              fontWeight: i % 90 == 0 ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          textDirection: TextDirection.ltr,
        );

        textPainter.layout();
        textPainter.paint(canvas, Offset(-(textPainter.width / 2), 0));
        canvas.restore();
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
