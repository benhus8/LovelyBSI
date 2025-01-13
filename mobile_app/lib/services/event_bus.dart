import 'dart:async';

class EventBus {
  final _starEventController = StreamController<int>.broadcast();
  final _resetProgressController = StreamController<void>.broadcast();

  Stream<int> get onStarToggled => _starEventController.stream;
  Stream<void> get onResetProgress => _resetProgressController.stream;

  void publishStarToggled(int questionId) {
    _starEventController.sink.add(questionId);
  }

  void publishResetProgress() {
    _resetProgressController.sink.add(null);
  }

  void dispose() {
    _starEventController.close();
    _resetProgressController.close();
  }
}

final eventBus = EventBus(); 