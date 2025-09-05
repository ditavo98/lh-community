import 'dart:async';

import 'package:lh_community/src/utils/collection_ex.dart';
import 'package:visibility_detector/visibility_detector.dart';

mixin CMPostItemVisibleMixin {
  int get postId;

  Timer? _visibleTimer;

  void onVisibilityChanged(VisibilityInfo info) {
    const feedViewedPostFraction = 1;
    const feedViewedPostDuration = 200;
    if (info.visibleFraction >= feedViewedPostFraction) {
      _visibleTimer?.cancel();
      _visibleTimer =
          Timer(const Duration(milliseconds: feedViewedPostDuration), () {
        onViewedItem();
        _visibleTimer?.cancel();
        _visibleTimer = null;
      });
    } else {
      _visibleTimer?.cancel();
      _visibleTimer = null;
    }
    onViewingItem(postId, info.visibleFraction);
  }

  void onViewedItem() {}

  void onViewingItem(int postId, double visibleFraction) {}

  void closeTimer() {
    _visibleTimer?.cancel();
  }
}

class VisibleManager {
  List<({int postId, double visibleFraction})> viewingPosts = [];

  VisibleManager._();

  static final VisibleManager _instance = VisibleManager._();

  static VisibleManager get instance => _instance;

  onViewingItem(int postId, double visibleFraction) {
    if (visibleFraction == 0) {
      viewingPosts.removeWhere((x) => x.postId == postId);
    } else {
      var postIndex = viewingPosts.indexWhere((x) => x.postId == postId);
      if (postIndex < 0) {
        viewingPosts.add((postId: postId, visibleFraction: visibleFraction));
      } else {
        viewingPosts[postIndex] =
            (postId: postId, visibleFraction: visibleFraction);
      }
    }
  }

  int getPostViewingLargest() {
    if (viewingPosts.isNullOrEmpty) return -1;
    var maxValue = viewingPosts[0];
    for (var p in viewingPosts) {
      if (p.visibleFraction > maxValue.visibleFraction) {
        maxValue = p;
      }
    }
    return maxValue.postId;
  }
}
