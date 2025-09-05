import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lh_community/lh_community.dart';
import 'package:lh_community/src/core/configs.dart';
import 'package:lh_community/src/core/model/post_dto.dart';
import 'package:lh_community/src/ui/common/auto_play_video/secured_video_view.dart';
import 'package:lh_community/src/utils/community_image.dart';
import 'package:lh_community/src/utils/collection_ex.dart';
import 'package:lh_community/src/utils/media_preview.dart';
import 'package:lh_community/src/utils/string_ex.dart';
import 'package:photo_view/photo_view.dart';

class CMFeedImageView extends StatefulWidget {
  final dynamic file;
  final List files;
  final double? aspectRatio;
  final CommunityPostDto? post;
  final int postType;
  final double? borderRadius;
  final EdgeInsets? padding;
  final bool inPreview, isViewFullSize, isSingle;
  final VoidCallback? logView;

  const CMFeedImageView({
    super.key,
    required this.file,
    required this.post,
    this.aspectRatio,
    this.postType = 1,
    this.padding,
    this.borderRadius,
    required this.files,
    this.inPreview = false,
    this.logView,
    this.isViewFullSize = false,
  }) : isSingle = false;

  const CMFeedImageView.single({
    super.key,
    required this.file,
    required this.post,
    this.postType = 1,
    this.padding,
    this.borderRadius,
    required this.files,
    this.logView,
  })  : aspectRatio = null,
        inPreview = false,
        isViewFullSize = false,
        isSingle = true;

  @override
  State<CMFeedImageView> createState() => _CMFeedImageViewState();
}

class _CMFeedImageViewState extends State<CMFeedImageView> {
  dynamic get selectedMedia => widget.file;

  List get mediaList => widget.files;

  EdgeInsets get _padding => widget.padding ?? EdgeInsets.zero;

  bool get _inPreview => widget.inPreview;

  bool get _isViewFullSize => widget.isViewFullSize;

  bool get _isSingleView => widget.isSingle;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double ratio = widget.aspectRatio ?? 1;
    dynamic mediaId;
    var thumbnailUrl = '';
    double? height;
    if (selectedMedia is CommunityFileElementDto) {
      var dto = (selectedMedia as CommunityFileElementDto);
      mediaId = dto.id;
      thumbnailUrl = dto.thumbnailUrl ?? '';
      if (_isViewFullSize) {
        thumbnailUrl = dto.url ?? '';
      }
      ratio = dto.displayRatio ?? 1;
      height = dto.height?.toDouble();
      final physicalWidth = MediaQuery.of(context).size.width - 40;
      height = physicalWidth / ratio;

      if (_inPreview) {
        return _photoView(dto.url);
      }
    }

    return InkWell(
      onTap: () async {
        List list = mediaList.toList();
        list.removeWhere((media) => media.url.toString().isNullOrEmpty);
        if (mediaList.isNullOrEmpty) return;
        final index = mediaList.indexWhere((media) => media.id == mediaId);
        var args = MediaPreviewArgument(
          dataList: mediaList,
          post: widget.post,
          postType: widget.postType,
          targetIndex: index,
        );
        widget.logView?.call();
        await MediaPreview.navigateMediaPreview(args);
      },
      child: Padding(
        padding: _padding,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.all(Radius.circular(widget.borderRadius ?? 0)),
            border: Border.all(
              color: CMColor.black.withValues(alpha: .06),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(1),
            child: _isSingleView
                ? SizedBox(
                    height: height,
                    child: CMImageView(
                      thumbnailUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      radius: widget.borderRadius,
                    ),
                  )
                : AspectRatio(
                    aspectRatio: ratio,
                    child: CMImageView(
                      thumbnailUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      radius: widget.borderRadius,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _photoView(dynamic source) {
    if (source is File) {
      return PhotoViewGestureDetectorScope(
        axis: Axis.vertical,
        child: PhotoView(
          imageProvider: FileImage(source),
          loadingBuilder: (_, __) {
            return const MediaLoadingProgress(visible: true);
          },
          minScale: PhotoViewComputedScale.contained * 1,
        ),
      );
    }
    if (source is String) {
      var url = source;
      if (!url.contains('http')) {
        var baseUrl = LHConfigs.mediaBaseUrl;
        url = '$baseUrl$url';
      }
      return PhotoViewGestureDetectorScope(
        axis: Axis.vertical,
        child: PhotoView(
          imageProvider: CachedNetworkImageProvider(
            url,
            cacheKey: source,
          ),
          loadingBuilder: (_, __) {
            return const MediaLoadingProgress(visible: true);
          },
          minScale: PhotoViewComputedScale.contained * 1,
        ),
      );
    }
    return SizedBox();
  }
}
