import 'dart:async';

import 'package:lh_community/src/core/api/api_client.dart';
import 'package:lh_community/src/core/di.dart';


class CMPostBatchViewsPool {
  late List<CMPostViewObject> posts;
  late Timer _batchTimer;
  bool _isSending = false;

  final feedSendBatchViewsDuration = 2000;
  final feedMaxNumbersPostToSend = 25;

  CMPostBatchViewsPool() {
    posts = [];
    _batchTimer = Timer.periodic(
      Duration(
        milliseconds: feedSendBatchViewsDuration,
      ),
      (_) => _onTimeToSend(),
    );
  }

  void addPostId(int? postId) {
    if (postId == null) {
      return;
    }
    posts.add(CMPostViewObject(postId: postId, time: DateTime.now()));
    if (posts.length > feedMaxNumbersPostToSend) {
      _onTimeToSend();
    }
  }

  Future? sendBatchViews() {
    return _onTimeToSend();
  }

  Future? _onTimeToSend() async {
    if (_isSending) return;
    if (posts.isNotEmpty) {
      _isSending = true;
      final sendingPosts = posts.toList();
      var postIds = sendingPosts.map((e) => e.postId).whereType<int>().toList();
      posts.clear();
      try {
        final data = {'ids': postIds, "type": "view"};
        getIt<ApiClient>().postViewLogs(data: data);
      } catch (_) {}
      _isSending = false;
      return;
    }
  }

  void close() {
    _batchTimer.cancel();
  }
}

class CMPostViewObject {
  final int? postId;
  final DateTime time;

  CMPostViewObject({
    required this.postId,
    required this.time,
  });

  @override
  String toString() => '_PostViewObject(postId: $postId, time: $time)';
}
