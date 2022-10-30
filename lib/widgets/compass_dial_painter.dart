import 'package:flutter/material.dart';

class CompassDialPainter extends CustomPainter {
  final dialPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = Colors.red;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final center = Offset(radius, radius);

    canvas.save();
    canvas.translate(radius, radius);

    var path = Path();

    path.addPolygon([
      Offset(-radius * 0.05, 0),
      Offset(-1.5, -radius * .78),
      Offset(0, -radius * .8),
      Offset(1.5, -radius * .78),
      Offset(radius * 0.05, 0),
    ], true);

    canvas.drawPath(path, dialPaint);
    path = Path();

    path.addPolygon([
      Offset(1.5, radius * .18),
      Offset(0, radius * .2),
      Offset(-1.5, radius * .18),
      Offset(-radius * 0.05, 0),
      Offset(radius * 0.05, 0)
    ], true);

    dialPaint.color = Colors.red;
    canvas.drawPath(path, dialPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
