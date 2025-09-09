import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lh_community/src/core/model/comment/comment_dto.dart';
import 'package:lh_community/src/core/model/post_dto.dart';
import 'package:lh_community/src/core/model/post_type_dto.dart';
import 'package:lh_community/src/ui/cubits/community_modify_post_cubit/community_modify_post_cubit.dart';
import 'package:lh_community/src/ui/cubits/post_detail_cubit/community_comment_cubit.dart';
import 'package:lh_community/src/ui/cubits/post_detail_cubit/community_post_detail_cubit.dart';
import 'package:lh_community/src/ui/widgets/fan_more_button.dart';
import 'package:lh_community/src/ui/widgets/post_view/post_view.dart';
import 'package:lh_community/src/utils/community_avatar.dart';
import 'package:lh_community/src/utils/community_color.dart';
import 'package:lh_community/src/utils/community_form_field.dart';
import 'package:lh_community/src/utils/community_image.dart';
import 'package:lh_community/src/utils/community_scaffold.dart';
import 'package:lh_community/src/utils/collection_ex.dart';
import 'package:lh_community/src/utils/datetime_ex.dart';
import 'package:lh_community/src/utils/dimen_mixin.dart';
import 'package:lh_community/src/utils/display_util.dart';
import 'package:lh_community/src/utils/lh_utils.dart';
import 'package:lh_community/src/utils/loadmore_widget.dart';
import 'package:lh_community/src/utils/my_app_bar.dart';
import 'package:lh_community/src/utils/no_data.dart';
import 'package:lh_community/src/utils/num_ex.dart';
import 'package:lh_community/src/utils/res.dart';
import 'package:lh_community/src/utils/string_ex.dart';
import 'package:lh_community/src/utils/text_style.dart';
import 'package:lh_community/src/utils/unfocus.dart';

class CMPostDetailArgs {
  final CommunityPostDto post;
  final SectionType sectionType;

  CMPostDetailArgs({required this.post, required this.sectionType});
}

class CMPostDetailScreen extends StatelessWidget {
  const CMPostDetailScreen({super.key});

  static Future navigated(BuildContext context, CMPostDetailArgs arg) {
    /*   EventLogManager().logs(
      screen: EventScreenType.fanBoardDetail003,
      event: EventType.open_support_post_detail,
      data: {'postId': arg.post.id},
    );*/
    return Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) {
          return MultiBlocProvider(providers: [
            BlocProvider(create: (context) => CMPostDetailCubit(arg)),
            BlocProvider(create: (context) => CMCommentCubit(arg.post)),
          ], child: CMPostDetailScreen());
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return UnFocus(
      child: CMScaffold(
        appBar: MyAppBar(
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: CMMoreButton(
                id: context.read<CMPostDetailCubit>().post.id ?? -1,
                communityUser: context.read<CMPostDetailCubit>().post.user,
              ),
            ),
          ],
        ),
        autoBodyPaddingImp: false,
        body: Padding(
          padding: Dimen.scaffoldPaddingHz,
          child: Column(
            children: [
              Expanded(
                child: BlocBuilder<CMPostDetailCubit, CMPostDetailState>(
                  builder: (context, state) {
                    if (state.initial) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return RefreshIndicator(
                      notificationPredicate: (notification) {
                        return notification.depth == 1;
                      },
                      onRefresh: () {
                        return context
                            .read<CMCommentCubit>()
                            .getComments(isRefresh: true);
                      },
                      child: NestedScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        headerSliverBuilder: (context, innerBoxIsScrolled) => [
                          SliverToBoxAdapter(
                              child: _postDetail(
                                  state.post,
                                  context
                                      .read<CMPostDetailCubit>()
                                      .args
                                      .sectionType)),
                        ],
                        body: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Divider(color: CMColor.grey2),
                            ),
                            Expanded(child: _commentList(state.post)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding:
                    EdgeInsets.only(top: 8, bottom: 8 + context.bottomSafeArea),
                child: Row(
                  children: [
                    Expanded(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 100),
                        child: CMFormField(
                          controller: context.read<CMCommentCubit>().cmtCtl,
                          fillColor: CMColor.grey2,
                          focusNode: context.read<CMCommentCubit>().cmtNode,
                          inputBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                            borderSide: BorderSide(color: CMColor.grey2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 20),
                          hintText: cmStr.text_enter_comment,
                        ),
                      ),
                    ),
                    Dimen.sBWidth8,
                    ClipOval(
                      child: ValueListenableBuilder(
                          valueListenable:
                              context.read<CMCommentCubit>().cmtCtl,
                          builder: (context, value, _) {
                            final enable = value.text.notNullOrEmpty;
                            return InkWell(
                              onTap: () {
                                if (enable) {
                                  UnFocus.call();
                                  context.read<CMCommentCubit>().onComment();
                                }
                              },
                              child: ColoredBox(
                                color:
                                    enable ? CMColor.primary5 : CMColor.grey4,
                                child: Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Icon(
                                    Icons.arrow_upward,
                                    size: 20,
                                    weight: 2,
                                    color: CMColor.white,
                                  ),
                                ),
                              ),
                            );
                          }),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _postDetail(CommunityPostDto post, SectionType type) {
    if (type == SectionType.feed || type == SectionType.gallery) {
      return CMFeedPostView.detail(post: post);
    }
    return CMBoardPostView.detail(post: post);
  }

  Widget _commentList(CommunityPostDto post) {
    return BlocListener<CMModifyPostCubit, CMModifyPostState>(
      listenWhen: (p, c) => c is DeleteCommentState,
      listener: (context, state) {
        switch (state) {
          case DeleteCommentState _:
            context.read<CMCommentCubit>().onDeleteComment(
                  commentId: state.commentId,
                  postId: state.postId,
                  parentId: state.parentId,
                );
            break;
          default:
            break;
        }
      },
      child: Column(
        children: [
          Expanded(
            child: BlocBuilder<CMCommentCubit, CMCommentState>(
              builder: (context, state) {
                if (state.initial) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.comments.isNullOrEmpty) {
                  return NoData(text: cmStr.text_no_comments_yet);
                }
                return LoadMore(
                  onLoadMore: () {
                    return context.read<CMCommentCubit>().getComments();
                  },
                  isFinish: state.isFinished,
                  child: ListView.separated(
                    itemBuilder: (context, index) {
                      return _CommentItem(
                        comment: state.comments[index],
                        onReply: (cmt) {
                          context.read<CMCommentCubit>().onReplyComment(cmt);
                        },
                      );
                    },
                    separatorBuilder: (_, __) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1, color: CMColor.grey2),
                    ),
                    itemCount: state.comments.length,
                  ),
                );
              },
            ),
          ),
          _replyView(),
        ],
      ),
    );
  }

  Widget _replyView() {
    return BlocBuilder<CMCommentCubit, CMCommentState>(
      buildWhen: (p, c) => p.replyComment != c.replyComment,
      builder: (context, state) {
        if (state.replyComment == null) return const SizedBox.shrink();
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            color: CMColor.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .05),
                offset: const Offset(0, -10),
                spreadRadius: 2,
                blurRadius: 10,
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: InkWell(
                    onTap: () {
                      context.read<CMCommentCubit>().onRemoveReply();
                    },
                    child: const Icon(Icons.close, size: 16),
                  ),
                ),
                _CommentItem.preview(comment: state.replyComment!)
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CommentItem extends StatelessWidget {
  final CommunityCommentDto comment;
  final bool isPreview, isReply;
  final ValueSetter<CommunityCommentDto>? onReply;

  const _CommentItem({super.key, required this.comment, this.onReply})
      : isPreview = false,
        isReply = false;

  const _CommentItem.preview({super.key, required this.comment})
      : isPreview = true,
        onReply = null,
        isReply = false;

  const _CommentItem.reply({super.key, required this.comment, this.onReply})
      : isPreview = false,
        isReply = true;

  List<CommunityCommentDto> get _replies => comment.replies ?? [];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  CMAvatar(avatar: comment.cmtAuthorAvatar, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    comment.cmtAuthorName ?? '',
                    style: LHTextStyle.subtitle3_1,
                  ),
                  Container(
                    width: 3,
                    height: 3,
                    decoration: BoxDecoration(
                      color: CMColor.greyN4,
                      shape: BoxShape.circle,
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  Text(
                    comment.createdAt.timeAgo(),
                    style: LHTextStyle.body3
                        .copyWith(height: 1.7, color: CMColor.grey6),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: !isPreview,
              child: CMMoreButton.comment(
                id: comment.id ?? -1,
                communityUser: comment.user,
                postId: comment.postId ?? -1,
                parentId: comment.parentCommentId,
                repliesCount: (comment.replies ?? []).length,
                onReported: () {
                  context.read<CMCommentCubit>().onReportComment(comment);
                },
                onBlocked: () {
                  context
                      .read<CMCommentCubit>()
                      .onBlockAuthorComment(comment.user?.id);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        ExpandableText(
          comment.comment ?? '',
          style: LHTextStyle.body1_1,
          expandText: cmStr.text_read_more,
          linkStyle: LHTextStyle.body1_1,
          collapseOnTextTap: false,
          maxLines: 2,
          linkColor: CMColor.grey5,
        ),
        if (!isPreview) ...[
          Dimen.sBHeight8,
          Row(children: [
            InkWell(
              onTap: () {
                context.read<CMCommentCubit>().onLike(comment);
              },
              child: Row(
                children: [
                  CMImageView(
                    key: ValueKey(comment.isLiked),
                    comment.isLiked == true
                        ? cmSvg.icHeart16Fill
                        : cmSvg.icHeart16,
                    size: 16,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    LHUtils.getShortValue(comment.likeCount.value),
                    style: LHTextStyle.body3.copyWith(color: CMColor.grey6),
                  )
                ],
              ),
            ),
            if (!isReply) ...[
              Dimen.sBWidth8,
              InkWell(
                onTap: () {
                  onReply?.call(comment);
                },
                child: Row(
                  children: [
                    CMImageView(
                      cmSvg.icChat01,
                      size: 16,
                      color: CMColor.grey6,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      LHUtils.getShortValue(comment.replyCount.value),
                      style: LHTextStyle.body3.copyWith(color: CMColor.grey6),
                    )
                  ],
                ),
              )
            ]
          ]),
        ],
        _repliesWidget(),
      ],
    );
  }

  Widget _repliesWidget() {
    if (_replies.isNullOrEmpty || isPreview || isReply) {
      return const SizedBox.shrink();
    }
    return ListView.separated(
      padding: const EdgeInsets.only(top: 16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemCount: _replies.length,
      itemBuilder: (context, index) {
        final item = _replies[index];
        return Padding(
          padding: const EdgeInsets.only(left: 16),
          child: _CommentItem.reply(
            comment: item,
            onReply: onReply,
          ),
        );
      },
    );
  }
}
