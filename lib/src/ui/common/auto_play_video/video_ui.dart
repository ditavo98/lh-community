import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:lh_community/src/utils/community_image.dart';
import 'package:lh_community/src/utils/res.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class MyFlickPortraitControls extends StatelessWidget {
  const MyFlickPortraitControls({
    Key? key,
    this.iconSize = 20,
    this.fontSize = 12,
    this.progressBarSettings,
    this.toggleMute,
    this.toggleFullscreen,
  }) : super(key: key);

  /// Icon size.
  ///
  /// This size is used for all the player icons.
  final double iconSize;

  /// Font size.
  ///
  /// This size is used for all the text.
  final double fontSize;

  /// [FlickProgressBarSettings] settings.
  final FlickProgressBarSettings? progressBarSettings;

  final Function? toggleMute;
  final Function? toggleFullscreen;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: FlickShowControlsAction(
            child: FlickSeekVideoAction(
              child: Center(
                child: FlickVideoBuffer(
                  child: FlickAutoHideChild(
                    child: FlickPlayToggle(
                      color: Colors.white,
                      playChild: CMImageView(
                          key: ValueKey(cmSvg.icPlay), cmSvg.icPlay),
                      pauseChild: CMImageView(
                          key: ValueKey(cmSvg.icPause), cmSvg.icPause),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Row(
                    spacing: 8,
                    children: [
                      FlickCurrentPosition(
                        fontSize: fontSize,
                      ),
                      Expanded(
                        child: FlickVideoProgressBar(
                          flickProgressBarSettings: progressBarSettings,
                        ),
                      ),
                      FlickTotalDuration(
                        fontSize: fontSize,
                      ),
                      FlickSoundToggle(
                        size: iconSize,
                        toggleMute: toggleMute,
                        unmuteChild: CMImageView(
                          key: ValueKey(cmSvg.icVolumeOn),
                          cmSvg.icVolumeOn,
                        ),
                        muteChild: CMImageView(
                          key: ValueKey(cmSvg.icVolumeOff),
                          cmSvg.icVolumeOff,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class MyFlickVideoWithControls extends StatefulWidget {
  const MyFlickVideoWithControls({
    Key? key,
    this.controls,
    this.videoFit = BoxFit.cover,
    this.playerLoadingFallback = const Center(
      child: CircularProgressIndicator(),
    ),
    this.playerErrorFallback = const Center(
      child: const Icon(
        Icons.error,
        color: Colors.white,
      ),
    ),
    this.backgroundColor = Colors.black,
    this.iconThemeData = const IconThemeData(
      color: Colors.white,
      size: 20,
    ),
    this.textStyle = const TextStyle(
      color: Colors.white,
      fontSize: 12,
    ),
    this.aspectRatioWhenLoading = 16 / 9,
    this.willVideoPlayerControllerChange = true,
    this.closedCaptionTextStyle = const TextStyle(
      color: Colors.white,
      fontSize: 12,
    ),
  }) : super(key: key);

  /// Create custom controls or use any of these [FlickPortraitControls], [FlickLandscapeControls]
  final Widget? controls;

  /// Conditionally rendered if player is not initialized.
  final Widget playerLoadingFallback;

  /// Conditionally rendered if player is has errors.
  final Widget playerErrorFallback;

  /// Property passed to [FlickVideoPlayer]
  final BoxFit videoFit;
  final Color backgroundColor;

  /// Used in [DefaultTextStyle]
  ///
  /// Use this property if you require to override the text style provided by the default Flick widgets.
  ///
  /// If any text style property is passed to Flick Widget at the time of widget creation, that style wont be overridden.
  final TextStyle textStyle;

  /// Used in [DefaultTextStyle]
  ///
  /// Use this property if you require to override the text style provided by the default ClosedCaption widgets.
  ///
  /// If any text style property is passed to Flick Widget at the time of widget creation, that style wont be overridden.
  final TextStyle closedCaptionTextStyle;

  /// Used in [IconTheme]
  ///
  /// Use this property if you require to override the icon style provided by the default Flick widgets.
  ///
  /// If any icon style is passed to Flick Widget at the time of widget creation, that style wont be overridden.
  final IconThemeData iconThemeData;

  /// If [FlickPlayer] has unbounded constraints this aspectRatio is used to take the size on the screen.
  ///
  /// Once the video is initialized, video determines size taken.
  final double aspectRatioWhenLoading;

  /// If false videoPlayerController will not be updated.
  final bool willVideoPlayerControllerChange;

  get videoPlayerController => null;

  @override
  _MyFlickVideoWithControlsState createState() =>
      _MyFlickVideoWithControlsState();
}

class _MyFlickVideoWithControlsState extends State<MyFlickVideoWithControls> {
  VideoPlayerController? _videoPlayerController;

  @override
  void didChangeDependencies() {
    VideoPlayerController? newController =
        Provider.of<FlickVideoManager>(context).videoPlayerController;
    if ((widget.willVideoPlayerControllerChange &&
            _videoPlayerController != newController) ||
        _videoPlayerController == null) {
      _videoPlayerController = newController;
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    FlickControlManager controlManager =
        Provider.of<FlickControlManager>(context);
    bool _showVideoCaption = controlManager.isSub;
    return IconTheme(
      data: widget.iconThemeData,
      child: LayoutBuilder(builder: (context, size) {
        return Container(
          color: widget.backgroundColor,
          child: DefaultTextStyle(
            style: widget.textStyle,
            child: Stack(
              children: <Widget>[
                Center(
                  child: _videoPlayerController != null
                      ? MyFlickNativeVideoPlayer(
                          videoPlayerController: _videoPlayerController!,
                          fit: widget.videoFit,
                          aspectRatioWhenLoading: widget.aspectRatioWhenLoading,
                        )
                      : widget.playerLoadingFallback,
                ),
                Positioned.fill(
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: <Widget>[
                      _videoPlayerController?.closedCaptionFile != null &&
                              _showVideoCaption
                          ? Positioned(
                              bottom: 5,
                              child: Transform.scale(
                                scale: 0.7,
                                child: ClosedCaption(
                                    textStyle: widget.closedCaptionTextStyle,
                                    text: _videoPlayerController!
                                        .value.caption.text),
                              ),
                            )
                          : SizedBox(),
                      if (_videoPlayerController?.value.hasError == false &&
                          _videoPlayerController?.value.isInitialized == false)
                        widget.playerLoadingFallback,
                      if (_videoPlayerController?.value.hasError == true)
                        widget.playerErrorFallback,
                      if (_videoPlayerController != null &&
                          _videoPlayerController!.value.isInitialized)
                        widget.controls ?? Container(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class MyFlickNativeVideoPlayer extends StatelessWidget {
  const MyFlickNativeVideoPlayer({
    Key? key,
    this.fit,
    this.aspectRatioWhenLoading,
    required this.videoPlayerController,
  }) : super(key: key);

  final BoxFit? fit;
  final double? aspectRatioWhenLoading;
  final VideoPlayerController? videoPlayerController;

  @override
  Widget build(BuildContext context) {
    VideoPlayer videoPlayer = VideoPlayer(videoPlayerController!);

    double? videoHeight = videoPlayerController?.value.size.height;
    double? videoWidth = videoPlayerController?.value.size.width;

    return LayoutBuilder(
      builder: (context, size) {
        double aspectRatio = (videoPlayerController?.value.isInitialized == true
                ? videoPlayerController?.value.aspectRatio
                : aspectRatioWhenLoading!) ??
            1;

        return AspectRatio(
          aspectRatio: aspectRatio,
          child: FittedBox(
            fit: fit!,
            child: videoPlayerController?.value.isInitialized == true
                ? Container(
                    height: videoHeight,
                    width: videoWidth,
                    child: videoPlayer,
                  )
                : Container(),
          ),
        );
      },
    );
  }
}
