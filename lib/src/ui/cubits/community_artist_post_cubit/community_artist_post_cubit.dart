import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lh_community/src/core/api/api_client.dart';
import 'package:lh_community/src/core/di.dart';
import 'package:lh_community/src/core/model/post_dto.dart';
import 'package:lh_community/src/core/model/post_type_dto.dart';
import 'package:lh_community/src/lh_community.dart';
import 'package:lh_community/src/ui/common/post_type_partner_data.dart';
import 'package:lh_community/src/ui/cubits/community_modify_post_cubit/community_post_listener.dart';
import 'package:lh_community/src/utils/cubit_mixin.dart';
import 'package:lh_community/src/utils/event_bus.dart';
import 'package:lh_community/src/utils/num_ex.dart';
import 'package:lh_community/src/utils/res.dart';

part 'community_artist_post_state.dart';

class CMArtistPostCubit extends Cubit<CMArtistPostState> with CubitMixin {
  final CMPostTypeDto artist;
  final CMSectionTypeDto sectionType;
  final ScrollController scrollController;

  CMArtistPostCubit({
    required this.artist,
    required this.sectionType,
    required this.scrollController,
  }) : super(CMArtistPostState()) {
    getPostOfArtist(isRefresh: true);
    _listener();
    _addPostListener();
  }

  final _apiClient = getIt<ApiClient>();

  StreamSubscription? _postListener;

  int _postPage = 0;
  final int _postSize = 25;

  StreamSubscription? _sub;

  CMPostTypePartnerData? get artistUser {
    final artists = LHCommunity().postTypePartnerData;
    return artists.firstWhereOrNull((x) => x.nickname == artist.name);
  }

  Future<bool> getPostOfArtist({bool isRefresh = false}) async {
    final curPost = List<CommunityPostDto>.from(state.postList);
    if (isRefresh) {
      curPost.clear();
      _postPage = 0;
    }
    _postPage++;
    bool result = false;
    await apiCall(
      callToHost: _apiClient.getPosts(
        page: _postPage,
        postTypeId: artist.id,
        sectionTypeId: sectionType.id,
        size: _postSize,
        includeFiles: kPostMediaLimit,
      ),
      success: (data) {
        final post = data.items ?? [];
        final isFinished = post.length < _postSize;
        curPost.addAll(post);
        emit(state.copyWith(
            initial: false, postList: curPost, isFinished: isFinished));
        result = isFinished;
      },
      error: (msg) {
        emit(state.copyWith(initial: false, isFinished: true));
      },
    );
    return !result;
  }

  onLike(CommunityPostDto post) {
    final curPost = List<CommunityPostDto>.from(state.postList);
    final index = curPost.indexWhere((x) => x.id == post.id);
    if (index < 0) return;
    var isLike = curPost[index].isLiked ?? false;
    var likeCount = curPost[index].likeCount.value;
    if (isLike) {
      likeCount--;
    } else {
      likeCount++;
    }
    if (likeCount < 0) likeCount = 0;
    curPost[index] = curPost[index].copyWith(
      isLiked: !isLike,
      likeCount: likeCount,
    );
    emit(state.copyWith(postList: curPost));
  }

  _listener() {
    _sub = LHEventBus.eventBus.on().listen((event) {
      if (event is ReloadSectionTypeEvent) {
        if (event.id != sectionType.id) return;
        getPostOfArtist(isRefresh: true).then((_) {
          Future.delayed(const Duration(milliseconds: 300), () {
            scrollController.animateTo(0,
                duration: const Duration(milliseconds: 30),
                curve: Curves.linear);
          });
        });
      }

      if (event is ForceReloadEvent) {
        getPostOfArtist(isRefresh: true);
      }
      if (event is SwitchingSectionType) {
        /*WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollController.animateTo(0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.linear);
        });*/
      }
    });
  }

  _addPostListener() {
    _postListener = PostListListener(
      postList: () => state.postList,
      onUpdatedPosts: (posts) => emit(state.copyWith(postList: posts)),
    ).listen();
  }

  @override
  Future<void> close() {
    _postListener?.cancel();
    _sub?.cancel();
    scrollController.dispose();
    return super.close();
  }
}
