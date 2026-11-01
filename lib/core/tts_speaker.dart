import 'package:flutter_tts/flutter_tts.dart';

import 'speaker.dart';

/// [Speaker] backed by the platform text-to-speech engine.
///
/// Every plugin call is guarded: a device without a TTS engine or without a
/// voice for the chosen language leaves [available] false and the app silent,
/// never broken.
final class TtsSpeaker extends Speaker {
  TtsSpeaker([FlutterTts? tts]) : _tts = tts ?? FlutterTts() {
    _tts.setStartHandler(() => _speaking = true);
    _tts.setCompletionHandler(_onFinished);
    _tts.setCancelHandler(_onFinished);
    _tts.setErrorHandler((_) => _onFinished());
  }

  static const Map<String, String> _locales = {'pl': 'pl-PL', 'en': 'en-US'};

  final FlutterTts _tts;
  bool _available = false;
  bool _speaking = false;

  /// Whether the line being spoken is a main (interrupting) line; hints are
  /// never queued behind another hint, so a child tapping around hears the
  /// hint once per teacher line, not once per tap.
  bool _currentIsMain = true;

  /// A non-interrupting line waiting for the current main line to finish;
  /// a newer one replaces an older one.
  (String text, String key)? _pending;

  /// The language set-up in flight; speech waits for it instead of being
  /// dropped while the engine is still initialising.
  Future<void>? _languageJob;

  @override
  bool get available => _available;

  @override
  Future<void> setLanguage(String languageCode) {
    final job = _applyLanguage(languageCode);
    _languageJob = job;
    return job;
  }

  Future<void> _applyLanguage(String languageCode) async {
    final locale = _locales[languageCode] ?? languageCode;
    final available = await _guard(() async {
      final result = await _tts.isLanguageAvailable(locale);
      if (result != true) {
        return false;
      }
      await _tts.setLanguage(locale);
      return true;
    });
    _available = available ?? false;
    notifyListeners();
  }

  @override
  Future<void> say(
    String text, {
    required String key,
    bool interrupt = true,
  }) async {
    await super.say(text, key: key, interrupt: interrupt);
    await _languageJob;
    if (!enabled || !_available) {
      return;
    }
    if (!interrupt && _speaking) {
      if (_currentIsMain) {
        _pending = (text, key);
      }
      return;
    }
    if (interrupt) {
      _pending = null;
    }
    await _speak(text, main: interrupt);
  }

  Future<void> _speak(String text, {required bool main}) async {
    _speaking = true;
    _currentIsMain = main;
    await _guard(() async {
      await _tts.setSpeechRate(rate.ttsRate);
      await _tts.stop();
      await _tts.speak(text);
      return true;
    });
  }

  void _onFinished() {
    _speaking = false;
    final pending = _pending;
    if (pending != null && enabled && _available) {
      _pending = null;
      _speak(pending.$1, main: false);
    }
  }

  @override
  Future<void> stop() async {
    _pending = null;
    _speaking = false;
    await _guard(() async {
      await _tts.stop();
      return true;
    });
  }

  /// Runs a plugin call; on any error marks speech unavailable and returns null.
  Future<T?> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on Exception {
      _available = false;
      return null;
    }
  }
}
