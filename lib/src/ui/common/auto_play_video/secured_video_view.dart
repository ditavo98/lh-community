import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:lh_community/src/core/model/post_dto.dart';
import 'package:lh_community/src/ui/common/auto_play_video/multi_video_play_manager.dart';
import 'package:lh_community/src/ui/common/auto_play_video/video_ui.dart';
import 'package:lh_community/src/utils/community_color.dart';
import 'package:lh_community/src/utils/community_image.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class CMVideoView extends StatefulWidget {
  final dynamic fileId;
  final dynamic source;
  final dynamic thumbnailUrl;
  final EdgeInsets padding;
  final double? borderRadius;

  /// use bring video state form the list to preview
  final FlickManager? flickManager;
  final bool isShowControl;

  final ValueNotifier<double>? aspectRatioNotifier;

  const CMVideoView({
    super.key,
    this.source,
    this.thumbnailUrl,
    this.padding = EdgeInsets.zero,
    this.borderRadius,
    this.fileId,
    this.flickManager,
    this.isShowControl = true,
    this.aspectRatioNotifier,
  });

  const CMVideoView.viewOnList({
    super.key,
    this.source,
    this.thumbnailUrl,
    this.padding = EdgeInsets.zero,
    this.borderRadius,
    this.fileId,
    required this.flickManager,
    this.isShowControl = true,
    this.aspectRatioNotifier,
  });

  @override
  State<CMVideoView> createState() => _CMVideoViewState();
}

class _CMVideoViewState extends State<CMVideoView> {
  FlickManager? _flickManager;
  String? url;

  double autoPlayVideViewedPostFraction = .5;

  dynamic get _fileId => '${widget.fileId ?? widget.source}';
  late ValueNotifier<double> _ratioNotifier;

  @override
  void initState() {
    _initData();
    super.initState();
  }

  void _initData() async {
    _ratioNotifier = widget.aspectRatioNotifier ?? ValueNotifier(1);
    if (widget.flickManager != null) {
      _flickManager = widget.flickManager!;
      _flickManager?.flickVideoManager?.videoPlayerController
          ?.addListener(_videoListener);
      return;
    }

    if (widget.source is String) {
      url = widget.source;
      _flickManager = FlickManager(
          videoPlayerController:
              VideoPlayerController.networkUrl(Uri.parse(url!))
                ..setLooping(true),
          autoPlay: false);
    } else if (widget.source is CommunityFileElementDto) {
      var fileElementDto = widget.source as CommunityFileElementDto;
      _flickManager = FlickManager(
          videoPlayerController:
              VideoPlayerController.networkUrl(Uri.parse(fileElementDto.url!))
                ..setLooping(true),
          autoPlay: false);
    } else {
      print('unknown video source');
    }

    if (_flickManager != null) {
      CMMultiVideoPlayManager.instance.init(_fileId, _flickManager!);
    }
    _flickManager?.flickVideoManager?.videoPlayerController
        ?.addListener(_videoListener);
  }

  void _videoListener() {
    VideoPlayerController? videoPlayer =
        _flickManager?.flickVideoManager?.videoPlayerController;
    if (_flickManager?.flickVideoManager?.isVideoInitialized == true) {
      var ratio = (videoPlayer?.value)?.aspectRatio ?? 1;
      if (_ratioNotifier.value != ratio) {
        _ratioNotifier.value = ratio;
        _flickManager?.flickVideoManager?.videoPlayerController
            ?.removeListener(_videoListener);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('${widget.fileId}_$url'),
      onVisibilityChanged: (visibilityInfo) {
        CMMultiVideoPlayManager.instance
            .onViewingItem(_fileId, visibilityInfo.visibleFraction);
      },
      child: Padding(
        padding: widget.padding,
        child: ClipRRect(
          child: _videoContainer(),
        ),
      ),
    );
  }

  Widget _videoContainer() {
    return _videoPlayerView();
    return Center(
      child: ValueListenableBuilder(
        valueListenable: _ratioNotifier,
        builder: (context, ratio, _) {
          return AspectRatio(
            aspectRatio: ratio,
            child: _videoPlayerView(),
          );
        },
      ),
    );
  }

  Widget _thumbnailContainer({bool isLoading = false}) {
    Widget? thumbnail;
    if (widget.source is String) {
      thumbnail = _VideoThumbnail(
        imageUrl: widget.thumbnailUrl,
        progressVisible: false,
      );
    }
    if (widget.source is CommunityFileElementDto) {
      var fileElementDto = widget.source as CommunityFileElementDto;

      thumbnail = _VideoThumbnail(
        imageUrl: fileElementDto.thumbnailUrl,
        progressVisible: false,
      );
    }
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black,
          child: Center(
            child: thumbnail,
          ),
        ),
        if (isLoading) const MediaLoadingProgress(),
      ],
    );
  }

  Widget _videoPlayerView() {
    if (_flickManager == null) {
      return _thumbnailContainer();
    }
    return FlickVideoPlayer(
      flickManager: _flickManager!,
      flickVideoWithControls: MyFlickVideoWithControls(
        controls: widget.isShowControl
            ? MyFlickPortraitControls(
                toggleMute: () {
                  CMMultiVideoPlayManager.instance.toggleMute();
                },
                progressBarSettings: FlickProgressBarSettings(
                  playedColor: CMColor.primary5,
                  bufferedColor: CMColor.borderColor,
                  height: 2,
                  handleColor: CMColor.primary5,
                  handleRadius: 5,
                ),
              )
            : null,
        aspectRatioWhenLoading: _ratioNotifier.value,
        playerLoadingFallback: _thumbnailContainer(isLoading: true),
        playerErrorFallback: _thumbnailContainer(),
      ),
    );
  }

  @override
  void dispose() {
    _flickManager?.flickVideoManager?.videoPlayerController
        ?.removeListener(_videoListener);
    if (widget.aspectRatioNotifier == null) {
      _ratioNotifier.dispose();
    }
    if (widget.flickManager == null && _flickManager != null) {
      CMMultiVideoPlayManager.instance.remove(_fileId, _flickManager!);
    }
    super.dispose();
  }
}

class _VideoThumbnail extends StatelessWidget {
  final String? imageUrl;
  final bool progressVisible;

  const _VideoThumbnail({
    this.imageUrl,
    this.progressVisible = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: [
        CMImageView(
          imageUrl,
          size: double.infinity,
          fit: BoxFit.contain,
        ),
        MediaLoadingProgress(visible: progressVisible)
      ],
    );
  }
}

class MediaLoadingProgress extends StatelessWidget {
  final bool visible;
  final double size;

  const MediaLoadingProgress({super.key, this.visible = true, this.size = 32});

  @override
  Widget build(BuildContext context) {
    if (visible) {
      return Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.4),
            ),
            child: Center(
              child: SizedBox(
                width: size * 0.8,
                height: size * 0.8,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
