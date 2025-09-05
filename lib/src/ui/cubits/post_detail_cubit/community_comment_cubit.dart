import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lh_community/src/core/api/api_client.dart';
import 'package:lh_community/src/core/di.dart';
import 'package:lh_community/src/core/model/comment/comment_dto.dart';
import 'package:lh_community/src/core/model/post_dto.dart';
import 'package:lh_community/src/lh_community.dart';
import 'package:lh_community/src/ui/cubits/community_modify_post_cubit/community_modify_post_cubit.dart';
import 'package:lh_community/src/utils/cubit_mixin.dart';
import 'package:lh_community/src/utils/num_ex.dart';

part 'community_comment_state.dart';

class CMCommentCubit extends Cubit<CMCommentState> with CubitMixin {
  final CommunityPostDto post;

  CMCommentCubit(this.post) : super(CMCommentState()) {
    getComments(isRefresh: true);
  }

  final limit = 25;
  int _page = 0;
  final _fanApi = getIt<ApiClient>();

  int get _postId => post.id ?? -1;

  final TextEditingController cmtCtl = TextEditingController();
  final FocusNode cmtNode = FocusNode();

  Future<bool> getComments({bool isRefresh = false}) async {
    final curComments = List<CommunityCommentDto>.from(state.comments);
    if (isRefresh) {
      curComments.clear();
      _page = 0;
    }
    _page++;
    bool result = false;
    await apiCall(
      callToHost: _fanApi.getComments(
        postId: _postId,
        page: _page,
        size: limit,
      ),
      success: (data) {
        final comments = data.items ?? [];
        curComments.addAll(comments);
        final isFinished = comments.length < limit;
        emit(state.copyWith(
            initial: false, comments: curComments, isFinished: isFinished));
        result = !isFinished;
      },
      error: (msg) {
        emit(state.copyWith(initial: false, isFinished: true));
      },
    );
    return result;
  }

  onComment() {
    final comment = cmtCtl.text.trim();
    final commentReq = CommunityCommentDto(
      postId: _postId,
      comment: comment,
      parentCommentId: state.replyComment?.id,
      nickname: LHCommunity().nickname,
      nicknameAvatarUrl: LHCommunity().avatar,
    );
    apiCall(
      callToHost: _fanApi.comment(comment: commentReq),
      showLoading: true,
      success: (data) {
        final curComments = List<CommunityCommentDto>.from(state.comments);
        if (data.parentCommentId != null) {
          final indexOf =
              curComments.indexWhere((x) => x.id == data.parentCommentId);
          if (indexOf >= 0) {
            var replyCount = curComments[indexOf].replyCount.value;
            replyCount++;
            final replies = List<CommunityCommentDto>.from(
                curComments[indexOf].replies ?? []);
            replies.insert(0, data);
            curComments[indexOf] = curComments[indexOf].copyWith(
              replies: replies,
              replyCount: replyCount,
            );
          }
        } else {
          curComments.insert(0, data);
        }
        emit(CMCommentState(
          initial: state.initial,
          isFinished: state.isFinished,
          comments: curComments,
        ));
        cmtCtl.clear();
        LHCommunity()
            .context
            .read<CMModifyPostCubit>()
            .onComment(postId: _postId, cmt: data);
      },
    );
  }

  onDeleteComment(
      {required int postId, required int commentId, int? parentId}) {
    if (postId != _postId) return;
    final curComments = List<CommunityCommentDto>.from(state.comments);
    if (parentId != null) {
      final indexOf = curComments.indexWhere((x) => x.id == parentId);
      if (indexOf < 0) return;
      final replies =
          List<CommunityCommentDto>.from(curComments[indexOf].replies ?? []);
      var replyCount = curComments[indexOf].replyCount.value;
      replyCount--;
      if (replyCount < 0) replyCount = 0;
      replies.removeWhere((x) => x.id == commentId);
      curComments[indexOf] = curComments[indexOf].copyWith(
        replies: replies,
        replyCount: replyCount,
      );
    } else {
      curComments.removeWhere((x) => x.id == commentId);
    }
    emit(state.copyWith(comments: curComments));
  }

  onReplyComment(CommunityCommentDto comment) {
    cmtNode.requestFocus();
    emit(state.copyWith(replyComment: comment));
  }

  onRemoveReply() {
    emit(CMCommentState(
      initial: state.initial,
      isFinished: state.isFinished,
      comments: state.comments,
    ));
  }

  onReportComment(CommunityCommentDto comment) {
    final curComments = List<CommunityCommentDto>.from(state.comments);
    if (comment.parentCommentId == null) {
      curComments.removeWhere((x) => x.id == comment.id);
    } else {
      final indexOf =
          curComments.indexWhere((x) => x.id == comment.parentCommentId);
      if (indexOf < 0) return;
      final replies =
          List<CommunityCommentDto>.from(curComments[indexOf].replies ?? []);
      replies.removeWhere((x) => x.id == comment.id);
      curComments[indexOf] = curComments[indexOf].copyWith(replies: replies);
    }
    emit(state.copyWith(comments: curComments));
  }

  onBlockAuthorComment(int? communityUserId) {
    if (communityUserId == null) return;
    final curComments = List<CommunityCommentDto>.from(state.comments);
    curComments.removeWhere((x) => x.user?.id == communityUserId);

    for (int i = 0; i < curComments.length; i++) {
      final replies =
          List<CommunityCommentDto>.from(curComments[i].replies ?? []);
      replies.removeWhere((x) => x.user?.id == communityUserId);
      curComments[i] = curComments[i].copyWith(replies: replies);
    }

    emit(state.copyWith(comments: curComments));
  }

  onLike(CommunityCommentDto comment) {
    apiCall(
      callToHost: _fanApi.likeComment(commentId: comment.id ?? -1),
      success: (data) {},
    );

    var curComments = List<CommunityCommentDto>.from(state.comments);
    if (comment.parentCommentId == null) {
      curComments = _modifyLikeItem(curComments, comment);
    } else {
      final indexOf =
          curComments.indexWhere((x) => x.id == comment.parentCommentId);
      if (indexOf < 0) return;
      var replies = curComments[indexOf].replies ?? [];
      replies = _modifyLikeItem(replies, comment);
      curComments[indexOf] = curComments[indexOf].copyWith(replies: replies);
    }
    emit(state.copyWith(comments: curComments));
  }

  List<CommunityCommentDto> _modifyLikeItem(
      List<CommunityCommentDto> cmtList, CommunityCommentDto cmt) {
    final replies = List<CommunityCommentDto>.from(cmtList);
    final repliedIndex = replies.indexWhere((x) => x.id == cmt.id);
    if (repliedIndex < 0) return replies;
    final isLike = replies[repliedIndex].isLiked ?? false;
    var likeCount = replies[repliedIndex].likeCount.value;
    if (isLike) {
      likeCount--;
      if (likeCount < 0) likeCount = 0;
    } else {
      likeCount++;
    }
    replies[repliedIndex] = replies[repliedIndex].copyWith(
      isLiked: !isLike,
      likeCount: likeCount,
    );
    return replies;
  }

  @override
  Future<void> close() {
    cmtCtl.dispose();
    cmtNode.dispose();
    return super.close();
  }
}
