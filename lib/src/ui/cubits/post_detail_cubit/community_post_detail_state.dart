part of 'community_post_detail_cubit.dart';

class CMPostDetailState {
  final bool initial;
  final CommunityPostDto post;

  CMPostDetailState({this.initial = true, required this.post});

  CMPostDetailState copyWith({
    bool? initial,
    CommunityPostDto? post,
  }) {
    return CMPostDetailState(
      initial: initial ?? this.initial,
      post: post ?? this.post,
    );
  }
}
