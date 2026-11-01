import 'dart:math';

import 'package:chess_for_kids/data/models.dart';
import 'package:chess_for_kids/engine/engine.dart';
import 'package:chess_for_kids/features/board/piece_image.dart';
import 'package:chess_for_kids/features/match/match_screen.dart';
import 'package:chess_for_kids/features/match/match_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

void main() {
  late TestApp app;
  const delay = Duration(milliseconds: 200);

  setUp(() async {
    app = await TestApp.create();
    await app.state.createProfile(
      name: 'Zosia',
      theme: TeacherTheme.vehicles,
      avatarIndex: 1,
    );
  });

  Finder sq(String name) => find.byKey(Key('sq-$name'));
  Finder pieceOn(String name) =>
      find.descendant(of: sq(name), matching: find.byType(PieceImage));

  Future<void> pumpMatch(WidgetTester tester, {Random? random}) async {
    await tester.pumpWidget(
      app.wrap(MatchScreen(thinkingDelay: delay, random: random ?? Random(1))),
    );
    await tester.pump();
    await tester.pump();
  }

  testWidgets(
    'a match saved after the child move resumes and the computer replies',
    (tester) async {
      await app.state.saveMatch(
        '{"version":1,"child":"white","level":"easy","moves":["e2e4"]}',
      );
      await pumpMatch(tester);
      expect(find.byKey(const Key('thinking')), findsOneWidget);
      expect(app.speaker.spoken.map((s) => s.$1), ['match.thinking']);
      // The restored last move slides in first.
      await tester.pump(const Duration(milliseconds: 250));
      expect(pieceOn('e4'), findsOneWidget);
      await tester.pump(delay);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();
      expect(
        app.state.currentProfile!.savedGameJson,
        contains('"moves":["e2e4","'),
      );
      expect(app.speaker.spoken.last.$1, 'match.yourMove');
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'a match saved after the computer reply resumes with the child to move',
    (tester) async {
      await app.state.saveMatch(
        '{"version":1,"child":"white","level":"easy","moves":["e2e4","e7e5"]}',
      );
      await pumpMatch(tester);
      await tester.pump(const Duration(milliseconds: 250));
      expect(pieceOn('e5'), findsOneWidget);
      expect(find.byKey(const Key('thinking')), findsNothing);
      expect(app.speaker.spoken.last.$1, 'match.yourMove');
      await tester.pumpAndSettle();
    },
  );

  testWidgets('a broken save starts a new match and is cleared', (
    tester,
  ) async {
    await app.state.saveMatch('{');
    await pumpMatch(tester);
    expect(tester.takeException(), isNull);
    expect(pieceOn('e2'), findsOneWidget);
    expect(app.speaker.spoken.last.$1, 'match.intro');
    await tester.pumpAndSettle();
    expect(app.state.currentProfile!.savedGameJson, isNull);
  });

  testWidgets('an illegal saved move also starts a new match', (tester) async {
    await app.state.saveMatch(
      '{"version":1,"child":"white","level":"easy","moves":["e2e5"]}',
    );
    await pumpMatch(tester);
    expect(tester.takeException(), isNull);
    expect(pieceOn('e2'), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets(
    'with the random setting the child can be black and the computer starts',
    (tester) async {
      await app.state.updateSettings(
        app.state.settings.copyWith(childColor: ChildColor.random),
      );
      var seed = 0;
      while (MatchSession.pickChildColor(ChildColor.random, Random(seed)) !=
          PieceColor.black) {
        seed++;
      }
      await pumpMatch(tester, random: Random(seed));
      expect(app.speaker.spoken.last.$1, 'match.introBlack');
      expect(
        tester.getTopLeft(sq('a8')).dy,
        greaterThan(tester.getTopLeft(sq('a1')).dy),
      );
      expect(find.byKey(const Key('thinking')), findsOneWidget);
      await tester.pump(delay);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();
      expect(
        app.state.currentProfile!.savedGameJson,
        contains('"child":"black"'),
      );
      await tester.pumpAndSettle();
    },
  );
}
