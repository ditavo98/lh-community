import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lh_community/src/core/model/post_dto.dart';
import 'package:lh_community/src/core/model/post_type_dto.dart';
import 'package:lh_community/src/ui/cubits/community_modify_post_cubit/community_modify_post_cubit.dart';
import 'package:lh_community/src/utils/community_color.dart';
import 'package:lh_community/src/utils/community_image.dart';
import 'package:lh_community/src/utils/datetime_ex.dart';
import 'package:lh_community/src/utils/lh_utils.dart';
import 'package:lh_community/src/utils/num_ex.dart';
import 'package:lh_community/src/utils/res.dart';
import 'package:lh_community/src/utils/text_style.dart';

class CMPostInteracts extends StatelessWidget {
  final CommunityPostDto post;
  final SectionType type;

  const CMPostInteracts({super.key, required this.post})
      : type = SectionType.board;

  const CMPostInteracts.feed({super.key, required this.post})
      : type = SectionType.feed;

  bool get onFeed => type == SectionType.feed;

  bool get onBoard => type == SectionType.board;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            spacing: 6,
            children: [
              if (!onFeed)
                Row(
                  children: [
                    CMImageView(cmSvg.icView, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      LHUtils.getShortValue(post.viewCount.value),
                      style: LHTextStyle.body3.copyWith(color: CMColor.grey6),
                    )
                  ],
                ),
              InkWell(
                onTap: () {
                  context.read<CMModifyPostCubit>().onLike(postId: post.id ?? -1);
                },
                child: Row(
                  children: [
                    CMImageView(
                      key: ValueKey(post.isLiked),
                      post.isLiked == true ? cmSvg.icHeart16Fill : cmSvg.icHeart16,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      LHUtils.getShortValue(post.likeCount.value),
                      style: LHTextStyle.body3.copyWith(color: CMColor.grey6),
                    )
                  ],
                ),
              ),
              Row(
                children: [
                  CMImageView(
                    cmSvg.icChat01,
                    size: 18,
                    color: CMColor.grey6,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    LHUtils.getShortValue(post.commentCount.value),
                    style: LHTextStyle.body3.copyWith(color: CMColor.grey6),
                  )
                ],
              ),
            ],
          ),
        ),
        if (!onFeed)
          Text(
            post.postedAt.timeAgo(),
            style: LHTextStyle.body3.copyWith(color: CMColor.grey6),
          )
      ],
    );
  }
}
