import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:lh_community/src/ui/common/community_shared_preference.dart';
import 'package:lh_community/src/utils/collection_ex.dart';

class CMMultiVideoPlayManager {
  CMMultiVideoPlayManager._();

  static final CMMultiVideoPlayManager _instance = CMMultiVideoPlayManager._();

  static CMMultiVideoPlayManager get instance => _instance;

  /// key: [fileId], [flickManager]
  final Map<String, FlickManager> _flickManagerMap = {};
  List<({String fileId, double visibleFraction})> viewingPosts = [];
  FlickManager? _activeManager;
  bool _isMute = false;

  late ValueNotifier<bool> videoVolumeEnabled;

  ensureInitialized() {
    var enableVolume =
        CMSharedPreference.getBool(LocalStorageKey.videoVolumeSetting);
    videoVolumeEnabled = ValueNotifier(enableVolume);
    _isMute = !enableVolume;
  }

  init(String fileId, FlickManager flickManager) {
    _flickManagerMap[fileId] = flickManager;
    if (_isMute) {
      flickManager.flickControlManager?.mute();
    } else {
      flickManager.flickControlManager?.unmute();
    }
  }

  remove(String fileId, FlickManager flickManager) {
    if (_activeManager == flickManager) {
      _activeManager = null;
    }
    flickManager.dispose();
    _flickManagerMap.removeWhere((key, value) => key == fileId);
  }

  /*togglePlay(String fileId) {
    if (_activeManager?.flickVideoManager?.isPlaying == true &&
        flickManager == _activeManager) {
      pause();
    } else {
      play(fileId);
    }
  }*/

  pause([String? fileId]) {
    if (fileId != null) {
      var videosToPause = _flickManagerMap[fileId];
      if (videosToPause?.flickVideoManager?.isPlaying == true) {
        videosToPause?.flickControlManager?.pause();
      }
    } else {
      if (_activeManager?.flickVideoManager?.isPlaying == true) {
        _activeManager?.flickControlManager?.pause();
      }
    }
  }

  play([String? fileId]) {
    if (fileId != null) {
      _activeManager?.flickControlManager?.pause();
      _activeManager = _flickManagerMap[fileId];
    }

    if (_isMute) {
      _activeManager?.flickControlManager?.mute();
    } else {
      _activeManager?.flickControlManager?.unmute();
    }
    if (_activeManager?.flickVideoManager?.isPlaying == true) return;
    _activeManager?.flickControlManager?.play();
  }

  toggleMute() {
    _activeManager?.flickControlManager?.toggleMute();
    _isMute = _activeManager?.flickControlManager?.isMute ?? false;
    videoVolumeEnabled.value = !_isMute;
    CMSharedPreference.setBool(LocalStorageKey.videoVolumeSetting, videoVolumeEnabled.value);
    var managers = _flickManagerMap.entries
        .map((e) => e.value.flickControlManager)
        .nonNulls;
    if (_isMute) {
      Future.wait([...managers.map((e) => e.mute())]);
    } else {
      Future.wait([...managers.map((e) => e.unmute())]);
    }
  }

  double autoPlayVideViewedPostFraction = .5;

  onViewingItem(String fileId, double visibleFraction) {
    if (visibleFraction <= autoPlayVideViewedPostFraction) {
      viewingPosts.removeWhere((x) => x.fileId == fileId);
      pause(fileId);
    } else {
      var fileIndex = viewingPosts.indexWhere((x) => x.fileId == fileId);
      if (fileIndex < 0) {
        viewingPosts.add((fileId: fileId, visibleFraction: visibleFraction));
      } else {
        viewingPosts[fileIndex] =
            (fileId: fileId, visibleFraction: visibleFraction);
      }
    }
    var currentPostViewingLargest = getPostViewingLargest();
    play(currentPostViewingLargest);
    print('VisibleManager $viewingPosts');
  }

  String getPostViewingLargest() {
    if (viewingPosts.isNullOrEmpty) return '';
    var maxValue = viewingPosts[0];
    for (var p in viewingPosts) {
      if (p.visibleFraction > maxValue.visibleFraction) {
        maxValue = p;
      }
    }
    return maxValue.fileId;
  }
}
