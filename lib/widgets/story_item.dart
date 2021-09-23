import 'package:flutter/material.dart';

class StoryItem {
  final Duration duration;
  bool shown;
  final Widget view;

  StoryItem(
    this.view, {
    required this.duration,
    this.shown = false,
  });
}
