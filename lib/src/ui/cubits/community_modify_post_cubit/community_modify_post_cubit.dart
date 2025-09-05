import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lh_community/src/core/api/api_client.dart';
import 'package:lh_community/src/core/di.dart';
import 'package:lh_community/src/core/model/comment/comment_dto.dart';
import 'package:lh_community/src/utils/cubit_mixin.dart';

part 'community_modify_post_state.dart';

class CMModifyPostCubit extends Cubit<CMModifyPostState> with CubitMixin {
  CMModifyPostCubit() : super(ModifyPostInitial());

  final _apiClient = getIt<ApiClient>();

  onLike({required int postId}) {
    apiCall(
      callToHost: _apiClient.likePost(postId: postId),
      success: (data) {
        emit(LikePostState(postId: postId));
      },
    );
  }

  onComment({required int postId, required CommunityCommentDto cmt}) {
    emit(CommentPostState(postId: postId, comment: cmt));
  }

  onBlockPost({required int userId}) {
    emit(BlockPostState(userId: userId));
  }

  onReportPost({required int postId}) {
    emit(ReportPostState(postId: postId));
  }

  onDeletePost({required int postId}) {
    emit(DeletePostState(postId: postId));
  }

  onDeleteComment({
    required int postId,
    required int commentId,
    int? parentId,
    int? replyCount,
  }) {
    emit(DeleteCommentState(
      commentId: commentId,
      postId: postId,
      parentId: parentId,
      replyCount: replyCount,
    ));
  }
}
