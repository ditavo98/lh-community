part of 'community_comment_cubit.dart';

class CMCommentState {
  final bool initial, isFinished;
  final List<CommunityCommentDto> comments;
  final CommunityCommentDto? replyComment;

  CMCommentState({
    this.initial = true,
    this.isFinished = false,
    this.comments = const [],
    this.replyComment,
  });

  CMCommentState copyWith({
    bool? initial,
    bool? isFinished,
    List<CommunityCommentDto>? comments,
    CommunityCommentDto? replyComment,
  }) {
    return CMCommentState(
      initial: initial ?? this.initial,
      isFinished: isFinished ?? this.isFinished,
      comments: comments ?? this.comments,
      replyComment: replyComment ?? this.replyComment,
    );
  }
}
