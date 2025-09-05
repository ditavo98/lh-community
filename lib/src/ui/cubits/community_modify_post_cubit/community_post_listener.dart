import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lh_community/src/core/model/comment/comment_dto.dart';
import 'package:lh_community/src/core/model/post_dto.dart';
import 'package:lh_community/src/lh_community.dart';
import 'package:lh_community/src/ui/cubits/community_modify_post_cubit/community_modify_post_cubit.dart';
import 'package:lh_community/src/utils/num_ex.dart';

class PostListListener {
  final ValueSetter<List<CommunityPostDto>>? onUpdatedPosts;
  final ValueGetter<List<CommunityPostDto>> postList;

  PostListListener({
    this.onUpdatedPosts,
    required this.postList,
  });

  StreamSubscription listen() {
    var modifyCubit = LHCommunity().context.read<CMModifyPostCubit>();
    return modifyCubit.stream.listen(
      (state) {
        switch (state) {
          case LikePostState _:
            _onLikePost(state.postId);
          case CommentPostState _:
            _onCommentPost(state.postId, state.comment);
          case ReportPostState _:
            _onReport(state.postId);
          case BlockPostState _:
            _onBlock(state.userId);
          case DeletePostState _:
            _onDeletePost(state.postId);
          case DeleteCommentState _:
            _onDeleteComment(
              state.postId,
              state.commentId,
              parentId: state.parentId,
              replyCount: state.replyCount,
            );
          default:
        }
      },
    );
  }

  _onLikePost(int postId) {
    var posts = List<CommunityPostDto>.from(postList());
    var pIndex = posts.indexWhere((x) => x.id == postId);
    if (pIndex < 0) return;
    final isFavorite = posts[pIndex].isLiked ?? false;
    var likeCount = posts[pIndex].likeCount.value;
    if (isFavorite) {
      likeCount--;
      if (likeCount < 0) likeCount = 0;
    } else {
      likeCount++;
    }
    posts[pIndex] =
        posts[pIndex].copyWith(isLiked: !isFavorite, likeCount: likeCount);
    onUpdatedPosts?.call(posts);
  }

  _onCommentPost(int postId, CommunityCommentDto comment) {
    var posts = List<CommunityPostDto>.from(postList());
    var pIndex = posts.indexWhere((x) => x.id == postId);
    if (pIndex < 0) return;
    var commentCount = posts[pIndex].commentCount.value;
    commentCount++;
    posts[pIndex] = posts[pIndex].copyWith(commentCount: commentCount);
    onUpdatedPosts?.call(posts);
  }

  _onReport(int postId) {
    var posts = List<CommunityPostDto>.from(postList());
    posts.removeWhere((x) => x.id == postId);
    onUpdatedPosts?.call(posts);
  }

  _onBlock(int userId) {
    var posts = List<CommunityPostDto>.from(postList());
    posts.removeWhere((x) => x.userId == userId);
    onUpdatedPosts?.call(posts);
  }

  _onDeletePost(int postId) {
    var posts = List<CommunityPostDto>.from(postList());
    posts.removeWhere((x) => x.id == postId);
    onUpdatedPosts?.call(posts);
  }

  _onDeleteComment(int postId, int commentId,
      {int? parentId, int? replyCount}) {
    var posts = List<CommunityPostDto>.from(postList());
    var pIndex = posts.indexWhere((x) => x.id == postId);
    if (pIndex < 0) return;
    var commentCount = posts[pIndex].commentCount.value;
    commentCount--;
    commentCount -= replyCount.value;
    if (commentCount < 0) commentCount = 0;
    posts[pIndex] = posts[pIndex].copyWith(commentCount: commentCount);
    onUpdatedPosts?.call(posts);
  }
}
