import 'package:flutter/material.dart';
import 'package:lh_community/src/core/model/post_dto.dart';
import 'package:lh_community/src/utils/community_avatar.dart';
import 'package:lh_community/src/utils/community_color.dart';
import 'package:lh_community/src/utils/collection_ex.dart';
import 'package:lh_community/src/utils/text_style.dart';

class CMPostMediaPreview extends StatelessWidget {
  final List<CommunityFileElementDto> media;

  const CMPostMediaPreview({super.key, required this.media});

  @override
  Widget build(BuildContext context) {
    if (media.isNullOrEmpty) return const SizedBox.shrink();
    return Stack(
      children: [
        CMAvatar(
          avatar: media.first.thumbnailUrl,
          size: 72,
        ),
        if (media.length > 1)
          Positioned(
            bottom: 4,
            right: 4,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: CMColor.black.withValues(alpha: .6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  '${media.length}',
                  style:
                      LHTextStyle.subtitle4_3.copyWith(color: CMColor.white),
                ),
              ),
            ),
          )
      ],
    );
  }
}
