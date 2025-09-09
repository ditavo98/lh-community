import 'dart:async';

class LHEventBus {
  static EventBus eventBus = EventBus();
}

class ReloadPostPage {}

class SwitchingSectionType {}

class ReloadSectionTypeEvent {
  final int id;

  ReloadSectionTypeEvent({required this.id});
}

//TODO chưa có làm cái này cần làm
class ForceReloadEvent {}

class ReloadPostTypeEvent {}

class EventBus {
  final StreamController _streamController;

  StreamController get streamController => _streamController;

  EventBus({bool sync = false})
      : _streamController = StreamController.broadcast(sync: sync);

  EventBus.customController(StreamController controller)
      : _streamController = controller;

  Stream<T> on<T>() {
    if (T == dynamic) {
      return streamController.stream as Stream<T>;
    } else {
      return streamController.stream.where((event) => event is T).cast<T>();
    }
  }

  void fire(event) {
    streamController.add(event);
  }

  void destroy() {
    _streamController.close();
  }
}
