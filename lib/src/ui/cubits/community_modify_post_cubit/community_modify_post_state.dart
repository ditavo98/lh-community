part of 'community_modify_post_cubit.dart';

@immutable
sealed class CMModifyPostState {}

final class ModifyPostInitial extends CMModifyPostState {}

final class LikePostState extends CMModifyPostState {
  final int postId;

  LikePostState({required this.postId});
}

final class CommentPostState extends CMModifyPostState {
  final int postId;
  final CommunityCommentDto comment;

  CommentPostState({
    required this.postId,
    required this.comment,
  });
}

final class ReportPostState extends CMModifyPostState {
  final int postId;

  ReportPostState({required this.postId});
}

final class BlockPostState extends CMModifyPostState {
  final int userId;

  BlockPostState({required this.userId});
}

final class DeletePostState extends CMModifyPostState {
  final int postId;

  DeletePostState({required this.postId});
}

final class DeleteCommentState extends CMModifyPostState {
  final int commentId;
  final int? parentId;
  final int? replyCount;
  final int postId;

  DeleteCommentState({
    required this.postId,
    required this.commentId,
    this.parentId,
    this.replyCount,
  });
}
