part of 'community_artist_post_cubit.dart';

class CMArtistPostState {
  final bool initial, isFinished;
  final List<CommunityPostDto> postList;

  CMArtistPostState({
    this.initial = true,
    this.postList = const [],
    this.isFinished = false,
  });

  CMArtistPostState copyWith({
    bool? initial,
    bool? isFinished,
    List<CommunityPostDto>? postList,
  }) {
    return CMArtistPostState(
      initial: initial ?? this.initial,
      isFinished: isFinished ?? this.isFinished,
      postList: postList ?? this.postList,
    );
  }
}
