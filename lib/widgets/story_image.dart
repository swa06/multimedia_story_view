import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'story_controller.dart';

class ImageLoader {
  ui.Codec? frames;
  String url;
  Map<String, dynamic>? requestHeaders;
  late LoadState state;
  BaseCacheManager? cacheManager;

  ImageLoader(this.url, {this.requestHeaders, this.cacheManager}) {
    state = LoadState.loading;
    if(cacheManager == null) cacheManager = DefaultCacheManager();
  }

  void loadImage(VoidCallback onComplete) {
    if (frames != null) {
      state = LoadState.success;
      onComplete();
    }

    var fileStream = cacheManager?.getFileStream(this.url,
        headers: this.requestHeaders as Map<String, String>?);

    fileStream?.listen(
      (fileResponse) {
        if (!(fileResponse is FileInfo)) return;

        if (frames != null) return;

        var imageBytes = fileResponse.file.readAsBytesSync();
        state = LoadState.success;

        PaintingBinding.instance?.instantiateImageCodec(imageBytes).then(
          (codec) {
            frames = codec;
          },
          onError: (error) {
            state = LoadState.failure;
          },
        ).whenComplete(() => onComplete());
      },
      onError: (error) {
        state = LoadState.failure;
        onComplete();
      },
    );
  }
}

class StoryImage extends StatefulWidget {
  final ImageLoader imageLoader;
  final BoxFit? fit;
  final StoryController controller;
  final double? height;
  final double? width;
  final VoidCallback? onStorySeen;

  StoryImage(
    this.imageLoader, {
    Key? key,
    required this.controller,
    this.height,
    this.width,
    this.fit,
    this.onStorySeen,
      }) : super(key: key ?? UniqueKey());

  factory StoryImage.url(
    String url, {
    required StoryController controller,
    Map<String, dynamic>? requestHeaders,
    BaseCacheManager? cacheManager,
    BoxFit fit = BoxFit.fitWidth,
    double height = 490.0,
    double width = 360.0,
    VoidCallback? onStorySeen,
    Key? key,
  }) {
    return StoryImage(
      ImageLoader(
        url,
        requestHeaders: requestHeaders,
        cacheManager: cacheManager,
      ),
      controller: controller,
      fit: fit,
      key: key,
      height: height,
      width: width,
      onStorySeen: onStorySeen
    );
  }

  @override
  State<StatefulWidget> createState() => _StoryImageState();
}

class _StoryImageState extends State<StoryImage> {
  ui.Image? _currentFrame;
  late final StreamSubscription<PlaybackState> _streamSubscription;

  @override
  void initState() {
    super.initState();
    _streamSubscription = widget.controller.playbackNotifier.listen((playbackState) {
      if (widget.imageLoader.frames == null) return;
      if (playbackState == PlaybackState.play) _forward();
    });
    widget.controller.pause();
    widget.imageLoader.loadImage(_onImageLoad);
  }

  void _onImageLoad() async {
    if (mounted) {
      if (widget.imageLoader.state == LoadState.success) {
        widget.controller.play();
        widget.onStorySeen?.call();
      } else {
        ///To display error widget
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void _forward() async {
    if (widget.controller.playbackNotifier.valueWrapper?.value == PlaybackState.pause) return;
    
    ui.FrameInfo? _nextFrame = await widget.imageLoader.frames?.getNextFrame();
    _currentFrame = _nextFrame?.image;
    setState(() {});
  }

  Widget _buildImageView() {
    switch (widget.imageLoader.state) {
      case LoadState.success:
        return RawImage(
          height: widget.height,
          width: widget.width,
          image: _currentFrame,
          fit: widget.fit,
        );
      case LoadState.failure:
        return Container(
          color: Colors.black38,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.65,
          child: Center(
              child: Text(
            "Image failed to load.",
            style: TextStyle(
              color: Colors.white,
            ),
          )),
        );
      default:
        return Container(
          color: Colors.black38,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.65,
          child: Center(
            child: Container(
              width: 70,
              height: 70,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                strokeWidth: 3,
              ),
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _buildImageView(),
    );
  }
}
