import 'package:chess_for_kids/app/constants.dart';
import 'package:chess_for_kids/app/route_observer.dart';
import 'package:chess_for_kids/app/theme/app_theme.dart';
import 'package:chess_for_kids/core/speaker.dart';
import 'package:chess_for_kids/data/models.dart';
import 'package:chess_for_kids/widgets/speak_button.dart';
import 'package:chess_for_kids/widgets/teacher_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  late FakeSpeaker fake;

  Widget wrap(Widget child) => ChangeNotifierProvider<Speaker>.value(
    value: fake,
    child: MaterialApp(
      navigatorObservers: [appRouteObserver],
      home: AppTheme(
        ui: uiPaletteById('sky'),
        board: boardPaletteById('classic'),
        child: Scaffold(body: child),
      ),
    ),
  );

  setUp(() => fake = FakeSpeaker());

  testWidgets('speaks on show and repeats on button tap', (tester) async {
    await tester.pumpWidget(
      wrap(
        const TeacherBubble(
          theme: TeacherTheme.animals,
          avatarIndex: 1,
          text: 'Hello',
          speechKey: 'k',
        ),
      ),
    );
    await tester.pump();
    expect(fake.spoken, [('k', 'Hello')]);
    await tester.tap(find.byType(SpeakButton));
    await tester.pump();
    expect(fake.spoken.length, 2);
    expect(find.text('Hello'), findsOneWidget);
  });

  testWidgets('speaks again when the text changes, not on unrelated rebuilds', (
    tester,
  ) async {
    Future<void> pumpText(String text) => tester.pumpWidget(
      wrap(
        TeacherBubble(
          theme: TeacherTheme.robots,
          avatarIndex: 2,
          text: text,
          speechKey: 'k',
        ),
      ),
    );
    await pumpText('One');
    await pumpText('One');
    expect(fake.spoken.length, 1);
    await pumpText('Two');
    expect(fake.spoken.map((s) => s.$2), ['One', 'Two']);
  });

  testWidgets('speakOnShow false stays silent until tapped', (tester) async {
    await tester.pumpWidget(
      wrap(
        const TeacherBubble(
          theme: TeacherTheme.ufo,
          avatarIndex: 3,
          text: 'Quiet',
          speechKey: 'k',
          speakOnShow: false,
        ),
      ),
    );
    expect(fake.spoken, isEmpty);
  });

  testWidgets('speak button meets the minimum touch target', (tester) async {
    await tester.pumpWidget(wrap(const SpeakButton()));
    expect(
      tester.getSize(find.byType(SpeakButton)).shortestSide,
      greaterThanOrEqualTo(kMinTouchTarget),
    );
  });

  testWidgets(
    'a bubble covered by another route stays quiet and speaks on return',
    (tester) async {
      var text = 'One';
      late StateSetter rebuild;
      await tester.pumpWidget(
        wrap(
          StatefulBuilder(
            builder: (context, setState) {
              rebuild = setState;
              return Column(
                children: [
                  TeacherBubble(
                    theme: TeacherTheme.animals,
                    avatarIndex: 1,
                    text: text,
                    speechKey: 'k',
                  ),
                  FilledButton(
                    key: const Key('cover'),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const Scaffold(body: Text('covering')),
                      ),
                    ),
                    child: const Text('cover'),
                  ),
                ],
              );
            },
          ),
        ),
      );
      await tester.pump();
      expect(fake.spoken.length, 1);
      await tester.tap(find.byKey(const Key('cover')));
      await tester.pumpAndSettle();
      rebuild(() => text = 'Two');
      await tester.pump();
      await tester.pump();
      expect(fake.spoken.length, 1, reason: 'spoke while covered');
      Navigator.of(tester.element(find.text('covering'))).pop();
      await tester.pumpAndSettle();
      expect(fake.spoken.map((s) => s.$2).toList(), ['One', 'Two']);
    },
  );
}
