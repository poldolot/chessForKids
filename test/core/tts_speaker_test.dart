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

  Future<void> platformSays(String method) async {
    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
          'flutter_tts',
          const StandardMethodCodec().encodeMethodCall(MethodCall(method)),
          (_) {},
        );
  }

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

  test('the cancel of the previous line does not report quiet', () async {
    // On a device the engine answers our stop() with speak.onCancel before
    // the new line starts; the hand-over must still count as speaking.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          if (call.method == 'isLanguageAvailable') {
            return true;
          }
          if (call.method == 'stop') {
            await platformSays('speak.onCancel');
          }
          return 1;
        });
    await speaker.setLanguage('pl');
    await speaker.say('Pierwsza', key: 'a');
    await platformSays('speak.onStart');
    expect(speaker.speaking.value, isTrue);
    await speaker.say('Druga', key: 'b');
    expect(speaker.speaking.value, isTrue, reason: 'hand-over to Druga');
    await platformSays('speak.onStart');
    await platformSays('speak.onComplete');
    expect(speaker.speaking.value, isFalse);
  });

  test('plugin errors are swallowed', () async {
    throwOnEverything = true;
    await speaker.setLanguage('pl');
    await expectLater(speaker.say('x', key: 'k'), completes);
    expect(speaker.available, isFalse);
  });

  test(
    'a non-interrupting line waits for the current one and then plays',
    () async {
      await speaker.setLanguage('pl');
      await speaker.say('Pierwsza', key: 'a');
      await platformSays('speak.onStart');
      await speaker.say('Podpowiedź', key: 'hint', interrupt: false);
      expect(named('speak').map((c) => c.arguments), ['Pierwsza']);
      expect(speaker.lastText, 'Pierwsza');
      await platformSays('speak.onComplete');
      await Future<void>.delayed(Duration.zero);
      expect(named('speak').map((c) => c.arguments), [
        'Pierwsza',
        'Podpowiedź',
      ]);
    },
  );

  test('the newest waiting line replaces an older one', () async {
    await speaker.setLanguage('pl');
    await speaker.say('Pierwsza', key: 'a');
    await speaker.say('Stara', key: 'h1', interrupt: false);
    await speaker.say('Nowa', key: 'h2', interrupt: false);
    await platformSays('speak.onComplete');
    await Future<void>.delayed(Duration.zero);
    expect(named('speak').map((c) => c.arguments), ['Pierwsza', 'Nowa']);
  });

  test(
    'a non-interrupting line plays at once when nothing is being spoken',
    () async {
      await speaker.setLanguage('pl');
      await speaker.say('Sama', key: 'h', interrupt: false);
      expect(named('speak').map((c) => c.arguments), ['Sama']);
    },
  );

  test('an interrupting line drops a waiting one', () async {
    await speaker.setLanguage('pl');
    await speaker.say('Pierwsza', key: 'a');
    await speaker.say('Czeka', key: 'h', interrupt: false);
    await speaker.say('Druga', key: 'b');
    await platformSays('speak.onComplete');
    await Future<void>.delayed(Duration.zero);
    expect(named('speak').map((c) => c.arguments), ['Pierwsza', 'Druga']);
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
    await fake.say('h', key: 'hint', interrupt: false);
    expect(fake.nonInterrupting, ['hint']);
    expect(fake.lastText, 'a');
    expect(fake.lastText, 'a');
    fake.enabled = false;
    await fake.say('b', key: 'k2');
    expect(fake.spoken.length, 2);
    expect(fake.lastText, 'b');
  });
}
