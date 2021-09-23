import 'package:flutter/material.dart';
import 'package:styling/styling.dart';
import 'oval_indicator.dart';

class StoryProgressIndicator extends StatelessWidget {
  final double value;
  final double indicatorHeight;

  StoryProgressIndicator(
    this.value, {
    this.indicatorHeight = 5,
  }) : assert(indicatorHeight > 0);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.fromHeight(
        indicatorHeight,
      ),
      foregroundPainter: OvalIndicator(
        white.withOpacity(0.8),
        value,
      ),
      painter: OvalIndicator(
        white.withOpacity(0.4),
        1.0,
      ),
    );
  }
}
