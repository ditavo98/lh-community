import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lh_community/src/core/model/post_dto.dart';
import 'package:lh_community/src/core/model/post_type_dto.dart';
import 'package:lh_community/src/ui/common/post_item_visible_mixin.dart';
import 'package:lh_community/src/ui/cubits/community_artist_post_cubit/community_artist_post_cubit.dart';
import 'package:lh_community/src/ui/widgets/fan_more_button.dart';
import 'package:lh_community/src/ui/widgets/feed_media_view.dart';
import 'package:lh_community/src/ui/widgets/image_view.dart';
import 'package:lh_community/src/ui/widgets/post_interacts.dart';
import 'package:lh_community/src/ui/widgets/video_view.dart';
import 'package:lh_community/src/utils/community_avatar.dart';
import 'package:lh_community/src/utils/community_color.dart';
import 'package:lh_community/src/utils/community_image.dart';
import 'package:lh_community/src/utils/community_read_more_text.dart';
import 'package:lh_community/src/utils/collection_ex.dart';
import 'package:lh_community/src/utils/datetime_ex.dart';
import 'package:lh_community/src/utils/dimen_mixin.dart';
import 'package:lh_community/src/utils/lh_utils.dart';
import 'package:lh_community/src/utils/num_ex.dart';
import 'package:lh_community/src/utils/res.dart';
import 'package:lh_community/src/utils/string_ex.dart';
import 'package:lh_community/src/utils/text_style.dart';
import 'package:visibility_detector/visibility_detector.dart';

part 'feed_post_view.dart';

part 'board_post_view.dart';
part 'gallery_post_view.dart';

class CMPostView extends StatefulWidget {
  final CommunityPostDto post;
  final VoidCallback? onView;
  final SectionType sectionType;

  const CMPostView({
    super.key,
    required this.post,
    this.onView,
    this.sectionType = SectionType.board,
  });

  @override
  State<CMPostView> createState() => _CMPostViewState();
}

class _CMPostViewState extends State<CMPostView> with CMPostItemVisibleMixin {
  @override
  int get postId => widget.post.id ?? -1;

  @override
  void onViewedItem() {
    super.onViewedItem();
    if (mounted) widget.onView?.call();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ValueKey('feed-item-${widget.post.id}'),
      onVisibilityChanged: onVisibilityChanged,
      child: _content(),
    );
  }

  Widget _content() {
    return switch (widget.sectionType) {
      SectionType.board => CMBoardPostView(post: widget.post),
      SectionType.feed => CMFeedPostView(post: widget.post),
      SectionType.gallery => CMGalleryPostView(post: widget.post),
      SectionType.fileboard => CMBoardPostView(post: widget.post),
      _ => CMBoardPostView(post: widget.post),
    };
  }
}
