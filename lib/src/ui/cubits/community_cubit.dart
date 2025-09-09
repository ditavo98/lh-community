import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lh_community/src/core/api/api_client.dart';
import 'package:lh_community/src/core/di.dart';
import 'package:lh_community/src/core/model/post_type_dto.dart';
import 'package:lh_community/src/lh_community.dart';
import 'package:lh_community/src/ui/common/post_batch_view_pool.dart';
import 'package:lh_community/src/utils/cubit_mixin.dart';
import 'package:lh_community/src/utils/event_bus.dart';

part 'community_state.dart';

class CMPostCubit extends Cubit<CMPostState> with CubitMixin {
  CMPostCubit() : super(CMPostState()) {
    getData();
    _listener();
    _postViewsController = CMPostBatchViewsPool();
  }

  final _apiClient = getIt<ApiClient>();

  StreamSubscription? _sub;

  late CMPostBatchViewsPool _postViewsController;

  getData() {
    var favoriteArtist = LHCommunity().postTypePartnerData;
    final ids = favoriteArtist.map((x) => x.id.toString()).toList();
    apiCall(
      callToHost: _apiClient.getPostType(projectTypeIds: ids),
      success: (data) {
        final items = data.items ?? [];
        final postTypes = <CMPostTypeDto>[];
        for (var id in ids) {
          final p = items.firstWhereOrNull((x) => x.projectTypeId == id);
          if (p == null) continue;
          postTypes.add(p);
        }

        final currentSelect =
            postTypes.firstWhereOrNull((x) => x.id == state.selectArtist?.id);
        emit(CMPostState(
          initial: false,
          artist: postTypes,
          selectArtist: currentSelect ?? postTypes.firstOrNull,
          sectionTypes: state.sectionTypes,
          selectSection: currentSelect != null ? state.selectSection : null,
        ));
        if (currentSelect == null) {
          onGetSectionTypes();
        }
      },
      error: (msg) {
        emit(state.copyWith(initial: false));
      },
    );
  }

  onSelectType(CMPostTypeDto artist) {
    emit(state.copyWith(selectArtist: artist));
    onGetSectionTypes();
  }

  onSelectSectionType(CMSectionTypeDto section) {
    emit(state.copyWith(selectSection: section));
  }

  _listener() {
    _sub = LHEventBus.eventBus.on().listen(
      (event) {
        if (event is ReloadPostPage || event is ReloadPostTypeEvent) {
          getData();
        }
      },
    );
  }

  onGetSectionTypes() {
    if (state.selectArtist == null) return;
    apiCall(
      callToHost: _apiClient.getSectionType(
        page: 1,
        size: 100,
        postTypeId: state.selectArtist?.id,
      ),
      success: (data) {
        final sectionTypes = data.items ?? [];
        emit(state.copyWith(
          initial: false,
          sectionTypes: sectionTypes,
          selectSection: state.selectSection ?? sectionTypes.firstOrNull,
        ));
      },
      error: (msg) {
        emit(state.copyWith(initial: false));
      },
    );
  }

  void viewItem(int? postId) {
    _postViewsController.addPostId(postId);
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    _postViewsController.close();
    return super.close();
  }
}
