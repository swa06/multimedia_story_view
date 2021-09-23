import 'dart:async';

import 'package:flutter/material.dart';
import 'package:styling/styling.dart';

import '../multimedia_story_view.dart';
import 'custom_stack.dart';
import 'story_page_bar.dart';

class StoryView extends StatefulWidget {
  final StoryItem storyItem;
  final StoryController storyController;
  final VoidCallback? onCloseButtonPressed;
  final Function(int) onAnimationCompleted;
  final int itemIndex;
  final Function(int) goToPreviousStory;
  final Function(int) goToNextStory;

  const StoryView({
    Key? key,
    required this.goToPreviousStory,
    required this.goToNextStory,
    required this.itemIndex,
    required this.onAnimationCompleted,
    required this.storyItem,
    required this.storyController,
    required this.onCloseButtonPressed,
  }) : super(key: key);

  @override
  _StoryViewState createState() => _StoryViewState();
}

class _StoryViewState extends State<StoryView> with SingleTickerProviderStateMixin {
  Animation<double>? _currentAnimation;
  late final AnimationController _animationController;
  Timer? _nextDebouncer;
  late StreamSubscription<PlaybackState> _playbackSubscription;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.storyItem.duration,
      vsync: this,
    );
    _currentAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);
    _animationController.addStatusListener(_onAnimationCompletion);
    _animationController.forward();

    _storyControllerStateChange();
  }

  void _storyControllerStateChange() {
    _playbackSubscription =
        widget.storyController.playbackNotifier.listen((state) {
      switch (state) {
        case PlaybackState.play:
          _removeNextHold();
          _animationController.forward();
          break;
        case PlaybackState.pause:
          _holdNext();
          _animationController.stop(canceled: false);
          break;
        case PlaybackState.next:
          _animationController.stop();
          _removeNextHold();
          widget.goToNextStory(widget.itemIndex);
          break;
        case PlaybackState.previous:
          _animationController.stop();
          _removeNextHold();
          widget.goToPreviousStory(widget.itemIndex);
          break;
        case PlaybackState.restart:
          _removeNextHold();
          _animationController.forward(from: 0.0);
          break;
      }
    });
  }

  void _holdNext() {
    _nextDebouncer?.cancel();
    _nextDebouncer = Timer(Duration(milliseconds: 500), () {});
  }

  void _removeNextHold() {
    _nextDebouncer?.cancel();
    _nextDebouncer = null;
  }

  void _onAnimationCompletion(status) {
    if (status == AnimationStatus.completed) {
      widget.onAnimationCompleted(widget.itemIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: white,
      child: CustomStack(
        children: <Widget>[
          SafeArea(
            child: widget.storyItem.view,
          ),
          _buildProgressBar(),
          _buildCloseButton(),
          _buildTapAreaRight(context),
          _buildTapAreaLeft(context),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nextDebouncer?.cancel();
    _nextDebouncer = null;
    _animationController.removeStatusListener(_onAnimationCompletion);
    _animationController.dispose();
    _playbackSubscription.cancel();
    super.dispose();
  }

  Align _buildTapAreaLeft(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      heightFactor: 1,
      child: SizedBox(
        child: GestureDetector(
          onTapDown: (details) {
            widget.storyController.pause();
            print("TAPDOWN");
          },
          onTapUp: (details) {
            print("TAP UP");
            if (_nextDebouncer?.isActive == false) {
              widget.storyController.play();
            } else {
              widget.storyController.previous();
            }
          }
        ),
        width: MediaQuery.of(context).size.width / 4,
      ),
    );
  }

  Align _buildTapAreaRight(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      heightFactor: 1.0,
      child: SizedBox(
        child: GestureDetector(
          onTapDown: (details) {
            widget.storyController.pause();
            print("TAPDOWN");
          },
          onTapCancel: () {
            widget.storyController.play();
            print("TAP CANCEL");
          },
          onTapUp: (details) {
            print("TAP UP");
            if (_nextDebouncer?.isActive == false) {
              widget.storyController.play();
            } else {
              widget.storyController.next();
            }
          },
        ),
        width: MediaQuery.of(context).size.width * 3 / 4,
      ),
    );
  }

  Align _buildCloseButton() {
    return Align(
      alignment: Alignment(0.92, -0.95),
      child: SafeArea(
        child: GestureDetector(
          onTap: () => widget.onCloseButtonPressed?.call(),
          child: Icon(
            Icons.close,
            size: 30,
            color: white,
          ),
        ),
      ),
    );
  }

  Align _buildProgressBar() {
    return Align(
      alignment: Alignment.topCenter,
      child: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: StoryPageBar(
            _currentAnimation,
            key: UniqueKey(),
          ),
        ),
      ),
    );
  }
}
