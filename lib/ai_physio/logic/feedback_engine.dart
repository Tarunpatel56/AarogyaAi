import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';

class FeedbackEngine {
  final FlutterTts flutterTts = FlutterTts();
  final double cooldown;
  int _lastFeedbackTime = 0;
  final StreamController<String> _feedbackQueueController =
      StreamController.broadcast();

  FeedbackEngine({this.cooldown = 2.0}) {
    flutterTts.setLanguage("en-US");
    flutterTts.setSpeechRate(0.5);

    _feedbackQueueController.stream.listen((feedback) {
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - _lastFeedbackTime >= (cooldown * 1000)) {
        flutterTts.speak(feedback);
        _lastFeedbackTime = now;
      }
    });
  }

  void queueFeedback(String feedback) {
    _feedbackQueueController.add(feedback);
  }

  void stop() {
    _feedbackQueueController.close();
    flutterTts.stop();
  }
}