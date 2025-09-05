import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:lh_community/src/core/model/post_dto.dart';
import 'package:lh_community/src/ui/common/auto_play_video/multi_video_play_manager.dart';
import 'package:lh_community/src/ui/common/auto_play_video/secured_video_view.dart';
import 'package:lh_community/src/utils/community_color.dart';
import 'package:lh_community/src/utils/community_image.dart';
import 'package:lh_community/src/utils/collection_ex.dart';
import 'package:lh_community/src/utils/lh_utils.dart';
import 'package:lh_community/src/utils/media_preview.dart';
import 'package:lh_community/src/utils/res.dart';
import 'package:lh_community/src/utils/string_ex.dart';
import 'package:lh_community/src/utils/text_style.dart';
import 'package:video_player/video_player.dart';

ValueNotifier<bool> previewPage = ValueNotifier(false);

class CMFeedVideoView extends StatefulWidget {
  final dynamic file;
  final List files;
  final double aspectRatio;
  final CommunityPostDto? post;
  final int postType;
  final double? borderRadius;
  final bool isViewFull;
  final VoidCallback? logView;

  const CMFeedVideoView({
    super.key,
    required this.file,
    required this.files,
    required this.aspectRatio,
    this.post,
    this.postType = 1,
    this.borderRadius,
    this.isViewFull = false,
    this.logView,
  });

  @override
  State<CMFeedVideoView> createState() => _CMFeedVideoViewState();
}

class _CMFeedVideoViewState extends State<CMFeedVideoView> {
  dynamic get selectedMedia => widget.file;

  List get mediaList => widget.files;

  FlickManager? _flickManager;

  String get fileId => '${selectedMedia.id ?? selectedMedia.url}';

  ValueNotifier<double>? _ratioNotifier;
  final ValueNotifier<Duration?> _durationNotifier = ValueNotifier(null);

  @override
  void initState() {
    _initData();
    super.initState();
  }

  void _initData() async {
    String? url;
    if (selectedMedia is CommunityFileElementDto) {
      var dto = (selectedMedia as CommunityFileElementDto);
      url = dto.url;
    }
    if (url.notNullOrEmpty) {
      _flickManager = FlickManager(
          videoPlayerController:
              VideoPlayerController.networkUrl(Uri.parse(url!))
                ..setLooping(true),
          autoPlay: false);
    }

    if (_flickManager != null) {
      CMMultiVideoPlayManager.instance.init(
        fileId,
        _flickManager!,
      );
    }
    _getRatio();
    _flickManager?.flickVideoManager?.videoPlayerController
        ?.addListener(_videoListener);
  }

  void _videoListener() async {
    VideoPlayerController? videoPlayer =
        _flickManager?.flickVideoManager?.videoPlayerController;
    VideoPlayerValue? videoPlayerValue =
        _flickManager?.flickVideoManager?.videoPlayerValue;
    final curPosition = await videoPlayer?.position;
    final totalTime = videoPlayerValue?.duration;
    if (totalTime != null && curPosition != null) {
      _durationNotifier.value = totalTime - curPosition;
    }
    if (_flickManager?.flickVideoManager?.isVideoInitialized == true) {
      var ratio = (videoPlayer?.value)?.aspectRatio ?? 1;
      if (_ratioNotifier?.value != ratio) {
        _ratioNotifier?.value = ratio;
        _flickManager?.flickVideoManager?.videoPlayerController
            ?.removeListener(_videoListener);
      }
    }
  }

  _getRatio() {
    var ratio = widget.aspectRatio;
    if (selectedMedia is CommunityFileElementDto) {
      var dto = (selectedMedia as CommunityFileElementDto);
      if (dto.displayRatio != null) ratio = dto.displayRatio!;
      _ratioNotifier = ValueNotifier(ratio);
    } else {
      _ratioNotifier = ValueNotifier(1);
    }
  }

  Widget get videosView {
    dynamic id;
    var thumbnailUrl = '';
    if (selectedMedia is CommunityFileElementDto) {
      var dto = (selectedMedia as CommunityFileElementDto);
      id = dto.id;
      thumbnailUrl = dto.thumbnailUrl ?? '';
    }
    return Stack(
      children: [
        CMVideoView.viewOnList(
          flickManager: _flickManager,
          thumbnailUrl: thumbnailUrl,
          fileId: id,
          source: thumbnailUrl,
          isShowControl: false,
          aspectRatioNotifier: _ratioNotifier,
        ),
        ValueListenableBuilder(
          valueListenable: previewPage,
          builder: (context, atPreviewPage, _) {
            if (atPreviewPage) return const SizedBox.shrink();
            return Container(color: Colors.transparent);
          },
        ),
      ],
    );
  }

  Widget get videosViewFull {
    dynamic id;
    if (selectedMedia is CommunityFileElementDto) {
      var dto = (selectedMedia as CommunityFileElementDto);
      id = dto.id;
    }
    return CMVideoView.viewOnList(
      flickManager: _flickManager,
      source: selectedMedia,
      thumbnailUrl: selectedMedia,
      fileId: id,
      isShowControl: true,
      aspectRatioNotifier: _ratioNotifier,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius ?? 0)),
      child: Builder(builder: (context) {
        dynamic mediaId;
        if (selectedMedia is CommunityFileElementDto) {
          var dto = (selectedMedia as CommunityFileElementDto);
          mediaId = dto.id;
          if (widget.isViewFull) {
            return videosViewFull;
          }
        }
        return GestureDetector(
          onTap: () async {
            List list = mediaList.toList();
            print('object');
            list.removeWhere((media) => media.url.toString().isNullOrEmpty);
            if (list.isNullOrEmpty) return;
            final index = list.indexWhere((media) => media.id == mediaId);
            var args = MediaPreviewArgument(
              dataList: list,
              post: widget.post,
              postType: widget.postType,
              targetIndex: index,
              currentView: videosViewFull,
            );
            widget.logView?.call();
            await MediaPreview.navigateMediaPreview(args);
          },
          child: Stack(
            children: [
              ColoredBox(color: Colors.black, child: videosView),
              Positioned.fill(
                  child: Align(
                      alignment: Alignment.bottomCenter, child: _myControl())),
            ],
          ),
        );
      }),
    );
  }

  void _switchEnableSound() {
    CMMultiVideoPlayManager.instance.toggleMute();
  }

  Widget _myControl() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _durationView(),
          GestureDetector(
            onTap: _switchEnableSound,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: Colors.black.withOpacity(.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: ValueListenableBuilder(
                  valueListenable:
                      CMMultiVideoPlayManager.instance.videoVolumeEnabled,
                  builder: (context, enableSound, child) {
                    return CMImageView(
                      key: ValueKey(enableSound),
                      enableSound ? cmSvg.icVolumeOn : cmSvg.icVolumeOff,
                      color: Colors.white,
                      size: 16,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _durationView() {
    return ValueListenableBuilder(
      valueListenable: _durationNotifier,
      builder: (context, duration, _) {
        if (duration == null) return const SizedBox.shrink();
        return Container(
          decoration: BoxDecoration(
            color: CMColor.black.withValues(alpha: .5),
            borderRadius: const BorderRadius.all(Radius.circular(4)),
          ),
          constraints: const BoxConstraints(minWidth: 45),
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
          child: Text(
            LHUtils.formatDuration2(duration),
            style:
                LHTextStyle.body3_1.copyWith(height: 1.2, color: CMColor.white),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _flickManager?.flickVideoManager?.videoPlayerController
        ?.removeListener(_videoListener);
    if (_flickManager != null) {
      CMMultiVideoPlayManager.instance.remove(fileId, _flickManager!);
    }
    _ratioNotifier?.dispose();
    _durationNotifier.dispose();
    super.dispose();
  }
}
