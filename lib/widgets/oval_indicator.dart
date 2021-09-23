import 'package:flutter/material.dart';

class OvalIndicator extends CustomPainter {
  final Color color;
  final double widthFactor;

  OvalIndicator(this.color, this.widthFactor);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paintProperties = Paint()..color = color;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width * widthFactor, size.height),
        Radius.circular(3),
      ),
      paintProperties,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
