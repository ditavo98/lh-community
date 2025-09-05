import 'package:flutter/material.dart';
import 'package:lh_community/src/core/model/post_dto.dart';
import 'package:lh_community/src/ui/widgets/image_view.dart';
import 'package:lh_community/src/ui/widgets/video_view.dart';
import 'package:lh_community/src/utils/community_color.dart';
import 'package:lh_community/src/utils/collection_ex.dart';
import 'package:lh_community/src/utils/dimen_mixin.dart';
import 'package:lh_community/src/utils/text_style.dart';
import 'package:preload_page_view/preload_page_view.dart';
class CMFeedMediaView extends StatefulWidget {
  final CommunityPostDto post;
  final double? borderRadius;

  final bool isDetail;

  const CMFeedMediaView({
    super.key,
    required this.post,
    this.borderRadius,
    this.isDetail = false,
  });

  @override
  State<CMFeedMediaView> createState() => _CMFeedMediaViewState();
}

class _CMFeedMediaViewState extends State<CMFeedMediaView> {
  //region Properties
  CommunityPostDto get post => widget.post;

  List<CommunityFileElementDto> get _files => List.from(post.files ?? []);

  bool get isMyPost => post.isMy;

  bool get isDetail => widget.isDetail;

  double get _aspectRatio {
    if (_files.notNullOrEmpty) {
      if (_files.first.ratio != null) {
        return _files.first.ratio ?? 1.0;
      }
    }
    return 1;
  }

  late PreloadPageController _controller;

  final ValueNotifier<int> _pageNotifier = ValueNotifier(0);

  @override
  void initState() {
    _controller = PreloadPageController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  //endregion
  @override
  Widget build(BuildContext context) {
    if (_files.isNullOrEmpty) return const SizedBox.shrink();
    if (isDetail) {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final e = _files[index];
          if (e.type == 'video') {
            return AspectRatio(
              aspectRatio: 1,
              child: CMFeedVideoView(
                file: e,
                files: _files,
                post: post,
                aspectRatio: _aspectRatio,
                borderRadius: widget.borderRadius,
              ),
            );
          } else {
            return ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 780),
              child: CMFeedImageView(
                file: e,
                files: _files,
                post: post,
                aspectRatio: _aspectRatio,
                borderRadius: widget.borderRadius,
                isViewFullSize: true,
              ),
            );
          }
        },
        separatorBuilder: (_, __) => Dimen.sBHeight8,
        itemCount: _files.length,
      );
    }
    return Stack(
      children: [
        PreloadPageView(
          controller: _controller,
          preloadPagesCount: 5,
          onPageChanged: (page) {
            _pageNotifier.value = page;
          },
          children: _files.map((e) {
            if (e.type == 'video') {
              return CMFeedVideoView(
                file: e,
                files: _files,
                post: post,
                aspectRatio: _aspectRatio,
                borderRadius: widget.borderRadius,
              );
            } else {
              return CMFeedImageView(
                file: e,
                files: _files,
                post: post,
                aspectRatio: _aspectRatio,
                borderRadius: widget.borderRadius,
              );
            }
          }).toList(),
        ),
        Positioned(top: 10, right: 10, child: _pageText())
      ],
    );
  }

  Widget _pageText() {
    if (_files.length <= 1) {
      return const SizedBox.shrink();
    }
    return ValueListenableBuilder<int>(
      valueListenable: _pageNotifier,
      builder: (context, value, _) {
        return Container(
          decoration: BoxDecoration(
            color: CMColor.black.withValues(alpha: .6),
            borderRadius: const BorderRadius.all(Dimen.radius16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${value + 1}/${_files.length}',
                  style: LHTextStyle.body4.copyWith(
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class MyPageViewScrollPhysics extends ScrollPhysics {
  const MyPageViewScrollPhysics({ScrollPhysics? parent})
      : super(parent: parent);

  @override
  MyPageViewScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return MyPageViewScrollPhysics(parent: buildParent(ancestor)!);
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 50,
        stiffness: 100,
        damping: 0.8,
      );
}
