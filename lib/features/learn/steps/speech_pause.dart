import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/speaker.dart';

/// A pause that does not start counting until the teacher is quiet.
///
/// Speech starts a moment after [Speaker.say] is called, so quiet is only
/// believed after [grace]; a line that never ends is given up on after
/// [timeout]. Demos use it so a move never cuts its own explanation short.
class SpeechPause {
  SpeechPause(this.speaker);

  final Speaker speaker;

  static const Duration grace = Duration(milliseconds: 200);
  static const Duration timeout = Duration(seconds: 20);

  Timer? _timer;
  VoidCallback? _listener;

  /// Runs [action] once it is quiet and [total] has passed in all (the
  /// grace included). A pause scheduled earlier is dropped.
  void schedule(Duration total, VoidCallback action) {
    cancel();
    final rest = total - grace;
    void startRest() {
      _timer = Timer(rest.isNegative ? Duration.zero : rest, action);
    }

    _timer = Timer(grace, () {
      if (!speaker.speaking.value) {
        startRest();
        return;
      }
      void quiet() {
        _detach();
        startRest();
      }

      _listener = () {
        if (!speaker.speaking.value) {
          quiet();
        }
      };
      speaker.speaking.addListener(_listener!);
      _timer = Timer(timeout, quiet);
    });
  }

  void _detach() {
    final listener = _listener;
    if (listener != null) {
      speaker.speaking.removeListener(listener);
      _listener = null;
    }
    _timer?.cancel();
    _timer = null;
  }

  /// Drops the pending pause, if any.
  void cancel() => _detach();
}
