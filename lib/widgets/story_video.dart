import 'dart:async';

import 'package:flutter/material.dart';
import 'package:multimedia_story_view/multimedia_story_view.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'story_controller.dart';

class StoryVideo extends StatefulWidget {
  final StoryController storyController;
  final String url;
  final double aspectRatio;
  final VoidCallback? onStorySeen;

  StoryVideo(
    this.url,
    this.storyController, {
    this.aspectRatio = 360 / 430,
    this.onStorySeen,
    Key? key,
  }) : super(key: key ?? UniqueKey());

  @override
  State<StatefulWidget> createState() {
    return _StoryVideoState();
  }
}

class _StoryVideoState extends State<StoryVideo> {
  StreamSubscription? _streamSubscription;
  late YoutubePlayerController playerController;
  late LoadState state;

  @override
  void initState() {
    super.initState();
    state = LoadState.failure;
    widget.storyController.pause();
    playerController = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(widget.url) ?? '',
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        hideThumbnail: true,
      ),
    );
    playerController.addListener(_onPlayerStateChange);
    _listenToPlaybackState();
  }

  void _listenToPlaybackState() {
    _streamSubscription = widget.storyController.playbackNotifier.listen((playbackState) {
      if (playbackState == PlaybackState.pause) {
        playerController.pause();
      } else {
        playerController.play();
      }
    });
  }

  void _onPlayerStateChange() {
    var _playerState = playerController.value.playerState;
    switch (_playerState) {
      case PlayerState.playing:
        if (state == LoadState.loading) {
          state = LoadState.success;
          widget.onStorySeen?.call();
          widget.storyController.play();
        }
        break;
      case PlayerState.buffering:
        state = LoadState.loading;
        break;
      case PlayerState.ended:
        playerController.pause();
        break;
      default:
        break;
    }
  }

  Widget _buildVideoView() {
    return YoutubePlayer(
      controller: playerController,
      aspectRatio: widget.aspectRatio,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildVideoView();
  }

  @override
  void dispose() {
    playerController.dispose();
    _streamSubscription?.cancel();
    super.dispose();
  }
}