import 'package:flutter/foundation.dart';

/// Speech tempo offered to parents in the settings.
enum SpeechRate {
  slow,
  normal,
  fast;

  /// Rate passed to the platform text-to-speech engine (0..1).
  double get ttsRate => switch (this) {
    slow => 0.35,
    normal => 0.5,
    fast => 0.65,
  };
}

/// Everything the app says out loud goes through a [Speaker].
///
/// Today the implementation is the system text-to-speech engine; later the
/// [key] passed to [say] will select a recorded clip.
abstract class Speaker extends ChangeNotifier {
  bool _enabled = true;
  SpeechRate _rate = SpeechRate.normal;
  String? _lastText;
  String? _lastKey;

  bool get enabled => _enabled;
  set enabled(bool value) {
    if (_enabled == value) {
      return;
    }
    _enabled = value;
    if (!value) {
      stop();
    }
    notifyListeners();
  }

  SpeechRate get rate => _rate;
  set rate(SpeechRate value) {
    if (_rate == value) {
      return;
    }
    _rate = value;
    notifyListeners();
  }

  /// Whether speech works for the current language on this device.
  bool get available;

  /// The last text handed to [say], spoken or not.
  String? get lastText => _lastText;

  /// Prepares voices for [languageCode] (`pl` or `en`).
  Future<void> setLanguage(String languageCode);

  /// Says [text]. [key] identifies the line for future recordings.
  /// Does nothing audible while [enabled] is false.
  @mustCallSuper
  Future<void> say(String text, {required String key}) async {
    _lastText = text;
    _lastKey = key;
  }

  /// Says the last text again.
  Future<void> repeat() async {
    final text = _lastText;
    final key = _lastKey;
    if (text != null && key != null) {
      await say(text, key: key);
    }
  }

  Future<void> stop();
}

/// In-memory speaker for tests and for the sandbox screen.
final class FakeSpeaker extends Speaker {
  final List<(String key, String text)> spoken = [];
  String? language;

  @override
  bool get available => true;

  @override
  Future<void> setLanguage(String languageCode) async {
    language = languageCode;
  }

  @override
  Future<void> say(String text, {required String key}) async {
    await super.say(text, key: key);
    if (enabled) {
      spoken.add((key, text));
    }
  }

  @override
  Future<void> stop() async {}
}
