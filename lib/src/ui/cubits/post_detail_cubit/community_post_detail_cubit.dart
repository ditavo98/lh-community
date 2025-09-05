import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lh_community/src/core/api/api_client.dart';
import 'package:lh_community/src/core/di.dart';
import 'package:lh_community/src/core/model/post_dto.dart';
import 'package:lh_community/src/lh_community.dart';
import 'package:lh_community/src/ui/cubits/community_modify_post_cubit/community_post_listener.dart';
import 'package:lh_community/src/ui/post_detail.dart';
import 'package:lh_community/src/utils/collection_ex.dart';
import 'package:lh_community/src/utils/cubit_mixin.dart';

part 'community_post_detail_state.dart';

class CMPostDetailCubit extends Cubit<CMPostDetailState> with CubitMixin {
  final CMPostDetailArgs args;

  CMPostDetailCubit(this.args)
      : super(CMPostDetailState(post: args.post, initial: false)) {
    _addPostListener();
  }

  final _fanApi = getIt<ApiClient>();

  CommunityPostDto get post => args.post;

  StreamSubscription? _postListener;

  getPostDetail() {
    apiCall(
      callToHost: _fanApi.getPost(id: post.id ?? -1),
      success: (data) {
        emit(state.copyWith(initial: false, post: data));
      },
      error: (msg) {
        emit(state.copyWith(initial: false));
      },
    );
  }

  _addPostListener() {
    _postListener = PostListListener(
      postList: () => [state.post],
      onUpdatedPosts: (posts) {
        if (posts.isNullOrEmpty) Navigator.pop(LHCommunity().context);
        emit(state.copyWith(post: posts.firstOrNull));
      },
    ).listen();
  }

  @override
  Future<void> close() {
    _postListener?.cancel();
    return super.close();
  }
}
