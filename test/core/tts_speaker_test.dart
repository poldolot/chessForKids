import 'dart:async';

import 'package:chess_for_kids/core/speaker.dart';
import 'package:chess_for_kids/core/tts_speaker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('flutter_tts');

  late List<MethodCall> calls;
  late bool languageAvailable;
  late bool throwOnEverything;
  late TtsSpeaker speaker;

  setUp(() {
    calls = [];
    languageAvailable = true;
    throwOnEverything = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          if (throwOnEverything) {
            throw PlatformException(code: 'no-tts');
          }
          if (call.method == 'isLanguageAvailable') {
            return languageAvailable;
          }
          return 1;
        });
    speaker = TtsSpeaker();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  Iterable<MethodCall> named(String method) =>
      calls.where((c) => c.method == method);

  test('say forwards to the plugin with language and rate', () async {
    await speaker.setLanguage('pl');
    speaker.rate = SpeechRate.slow;
    await speaker.say('Cześć', key: 'menu.greeting');
    expect(
      calls.map((c) => c.method),
      containsAllInOrder([
        'isLanguageAvailable',
        'setLanguage',
        'setSpeechRate',
        'stop',
        'speak',
      ]),
    );
    expect(named('setLanguage').last.arguments, 'pl-PL');
    expect(named('setSpeechRate').last.arguments, SpeechRate.slow.ttsRate);
    expect(speaker.lastText, 'Cześć');
    expect(speaker.available, isTrue);
  });

  test(
    'say issued right after setLanguage waits for the language to be ready',
    () async {
      unawaited(speaker.setLanguage('pl'));
      await speaker.say('Cześć', key: 'k');
      expect(named('speak').length, 1);
      expect(speaker.available, isTrue);
    },
  );

  test('english maps to en-US', () async {
    await speaker.setLanguage('en');
    expect(named('setLanguage').last.arguments, 'en-US');
  });

  test('disabled speaker stays silent but remembers the text', () async {
    await speaker.setLanguage('pl');
    speaker.enabled = false;
    await speaker.say('x', key: 'k');
    expect(named('speak'), isEmpty);
    expect(speaker.lastText, 'x');
  });

  test('repeat speaks the last text again', () async {
    await speaker.setLanguage('pl');
    await speaker.say('x', key: 'k');
    await speaker.repeat();
    expect(named('speak').length, 2);
  });

  test(
    'unavailable language marks the speaker unavailable and does not throw',
    () async {
      languageAvailable = false;
      await speaker.setLanguage('en');
      expect(speaker.available, isFalse);
      await speaker.say('hello', key: 'k');
      expect(named('speak'), isEmpty);
    },
  );

  test('plugin errors are swallowed', () async {
    throwOnEverything = true;
    await speaker.setLanguage('pl');
    await expectLater(speaker.say('x', key: 'k'), completes);
    expect(speaker.available, isFalse);
  });

  test('speech rate values are ordered', () {
    expect(SpeechRate.slow.ttsRate, lessThan(SpeechRate.normal.ttsRate));
    expect(SpeechRate.normal.ttsRate, lessThan(SpeechRate.fast.ttsRate));
  });

  test('FakeSpeaker records keys, texts and language', () async {
    final fake = FakeSpeaker();
    await fake.setLanguage('en');
    await fake.say('a', key: 'k1');
    expect(fake.spoken, [('k1', 'a')]);
    expect(fake.language, 'en');
    expect(fake.lastText, 'a');
    fake.enabled = false;
    await fake.say('b', key: 'k2');
    expect(fake.spoken.length, 1);
    expect(fake.lastText, 'b');
  });
}
