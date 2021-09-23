import 'package:flutter/material.dart';

import 'story_progress_indicator.dart';

class StoryPageBar extends StatefulWidget {
  final Animation<double>? animation;

  StoryPageBar(
    this.animation, {
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StoryPageBarState();
  }
}

class StoryPageBarState extends State<StoryPageBar> {
  @override
  void initState() {
    super.initState();
    widget.animation?.addListener(() {
      setState(() {});
    });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StoryProgressIndicator(
        widget.animation!.value,
        indicatorHeight: 5,
      ),
    );
  }
}
