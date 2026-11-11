import 'package:chess_for_kids/core/speaker.dart';
import 'package:chess_for_kids/features/learn/steps/speech_pause.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeSpeaker speaker;
  late SpeechPause pause;
  late int fired;
  setUp(() {
    speaker = FakeSpeaker();
    pause = SpeechPause(speaker);
    fired = 0;
  });
  tearDown(() => pause.cancel());

  testWidgets('fires after the whole delay when nothing is spoken', (
    tester,
  ) async {
    pause.schedule(const Duration(milliseconds: 600), () => fired++);
    await tester.pump(const Duration(milliseconds: 599));
    expect(fired, 0);
    await tester.pump(const Duration(milliseconds: 1));
    expect(fired, 1);
  });

  testWidgets('waits for a line that starts within the grace period', (
    tester,
  ) async {
    pause.schedule(const Duration(milliseconds: 600), () => fired++);
    await tester.pump(const Duration(milliseconds: 100));
    speaker.speaking.value = true;
    await tester.pump(const Duration(seconds: 3));
    expect(fired, 0);
    speaker.speaking.value = false;
    await tester.pump(const Duration(milliseconds: 399));
    expect(fired, 0);
    await tester.pump(const Duration(milliseconds: 1));
    expect(fired, 1);
  });

  testWidgets('gives up on a line that never ends', (tester) async {
    speaker.speaking.value = true;
    pause.schedule(const Duration(milliseconds: 600), () => fired++);
    await tester.pump(SpeechPause.grace);
    await tester.pump(SpeechPause.timeout);
    expect(fired, 0);
    await tester.pump(const Duration(milliseconds: 400));
    expect(fired, 1);
  });

  testWidgets('cancel and reschedule drop the earlier pause', (tester) async {
    pause.schedule(const Duration(milliseconds: 600), () => fired++);
    await tester.pump(const Duration(milliseconds: 300));
    pause.schedule(const Duration(milliseconds: 600), () => fired += 10);
    await tester.pump(const Duration(milliseconds: 600));
    expect(fired, 10);
    pause.schedule(const Duration(milliseconds: 600), () => fired++);
    pause.cancel();
    await tester.pump(const Duration(seconds: 1));
    expect(fired, 10);
  });
}
