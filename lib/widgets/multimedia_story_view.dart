import 'package:flutter/material.dart';
import 'package:multimedia_story_view/widgets/cube_page_view.dart';

import 'story_controller.dart';
import 'story_item.dart';
import 'story_view.dart';

class MultiMediaStoryView extends StatefulWidget {
  final List<StoryItem> storyItems;
  final StoryController controller;
  final VoidCallback? onComplete;
  final VoidCallback? onCloseButtonPressed;

  MultiMediaStoryView({
    Key? key,
    required this.storyItems,
    required this.controller,
    this.onComplete,
    this.onCloseButtonPressed,
  }) : super(key: key);

  @override
  _MultiMediaStoryViewState createState() => _MultiMediaStoryViewState();
}

class _MultiMediaStoryViewState extends State<MultiMediaStoryView> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  void _animationCompleted(int index) {
    if (index < widget.storyItems.length - 1) {
      _pageController.animateToPage(
        index + 1,
        duration: Duration(milliseconds: 1000),
        curve: Curves.ease,
      );
    } else {
      _onComplete();
    }
  }

  void _goForward(int index) {
    if (index < widget.storyItems.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 1),
        curve: Curves.ease,
      );
      widget.controller.play();
    } else {
      _onComplete();
    }
  }

  void _goBackward(int index) {
    if (index > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 1),
        curve: Curves.ease,
      );
      widget.controller.play();
    } else {
      widget.controller.restart();
    }
  }

  void _onComplete() {
    if (widget.onComplete != null) {
      widget.controller.pause();
      widget.onComplete!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CubePageView(
      controller: _pageController,
      children: widget.storyItems
          .map((item) => StoryView(
              itemIndex: widget.storyItems.indexOf(item),
              storyItem: item,
              storyController: widget.controller,
              onCloseButtonPressed: widget.onCloseButtonPressed,
              onAnimationCompleted: _animationCompleted,
              goToNextStory: _goForward,
              goToPreviousStory: _goBackward,
            ),
          ).toList(),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
