import 'dart:math';

import 'package:chess_for_kids/data/models.dart';
import 'package:chess_for_kids/engine/engine.dart';
import 'package:chess_for_kids/features/match/match_result_view.dart';
import 'package:chess_for_kids/features/match/match_screen.dart';
import 'package:chess_for_kids/features/match/match_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

void main() {
  late TestApp app;

  setUp(() async {
    app = await TestApp.create();
    await app.state.createProfile(
      name: 'Zosia',
      theme: TeacherTheme.ufo,
      avatarIndex: 1,
    );
    await app.state.saveMatch(
      '{"version":1,"child":"white","level":"easy","moves":[]}',
    );
  });

  Move uci(String u) => Move.parseUci(u);
  Finder sq(String name) => find.byKey(Key('sq-$name'));

  MatchSession wonByChild() {
    final s = MatchSession.fromJson({
      'version': 1,
      'child': 'black',
      'level': 'easy',
      'moves': ['f2f3', 'e7e5', 'g2g4'],
    }, random: Random(1));
    s.playChild(uci('d8h4'));
    return s;
  }

  MatchSession resigned() =>
      MatchSession(childColor: PieceColor.white, random: Random(1))
        ..playChild(uci('e2e4'))
        ..resign();

  MatchSession stalemated() => MatchSession(
    childColor: PieceColor.white,
    start: Position.fromFen('7k/8/6Q1/8/8/8/8/K7 w - - 0 1'),
    random: Random(1),
  )..playChild(uci('g6f7'));

  Future<void> pumpResult(
    WidgetTester tester,
    MatchSession session, {
    VoidCallback? onAgain,
  }) async {
    await tester.pumpWidget(
      app.wrap(
        Scaffold(
          body: MatchResultView(
            session: session,
            onAgain: onAgain ?? () {},
            onBack: () {},
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  testWidgets('a win records three stars, the trophy and the first badges', (
    tester,
  ) async {
    await pumpResult(tester, wonByChild());
    final p = app.state.currentProfile!;
    expect(p.matchStars, 3);
    expect(p.matchesPlayed, 1);
    expect(p.matchesWon, 1);
    expect(p.savedGameJson, isNull);
    expect(p.badges, containsAll(['firstMatch', 'firstWin']));
    expect(app.speaker.spoken.last.$1, 'match.won');
    expect(find.byKey(const Key('result-icon-trophy')), findsOneWidget);
    expect(find.byKey(const Key('result-badge')), findsNothing);
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.byKey(const Key('result-star-0')), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byKey(const Key('result-badge')), findsOneWidget);
    expect(app.speaker.spoken.last.$1, 'match.badgeFirstMatch');
    expect(app.speaker.nonInterrupting, contains('match.badgeFirstMatch'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('result-star-2')), findsOneWidget);
  });

  testWidgets('resigning records one star and consolation, no win', (
    tester,
  ) async {
    await pumpResult(tester, resigned());
    final p = app.state.currentProfile!;
    expect(p.matchStars, 1);
    expect(p.matchesPlayed, 1);
    expect(p.matchesWon, 0);
    expect(p.badges, contains('firstMatch'));
    expect(p.badges, isNot(contains('firstWin')));
    expect(app.speaker.spoken.last.$1, 'match.resigned');
    expect(find.byKey(const Key('result-icon-consolation')), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('result-star-1')), findsNothing);
  });

  testWidgets('stalemate records two stars and a handshake', (tester) async {
    await pumpResult(tester, stalemated());
    expect(app.state.currentProfile!.matchStars, 2);
    expect(app.speaker.spoken.last.$1, 'match.stalemate');
    expect(find.byKey(const Key('result-icon-handshake')), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('back and again buttons are there and call back', (tester) async {
    var again = 0;
    await pumpResult(tester, resigned(), onAgain: () => again++);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('result-back')), findsOneWidget);
    await tester.tap(find.byKey(const Key('result-again')));
    expect(again, 1);
  });

  testWidgets(
    'in the match screen the board stays put and again starts a new match',
    (tester) async {
      final s = MatchSession(childColor: PieceColor.white, random: Random(1));
      await tester.pumpWidget(
        app.wrap(
          MatchScreen(
            session: s,
            thinkingDelay: Duration.zero,
            random: Random(1),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      final a1 = tester.getRect(sq('a1'));
      await tester.tap(find.byKey(const Key('match-resign')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('resign-yes')));
      await tester.pumpAndSettle();
      expect(find.byType(MatchResultView), findsOneWidget);
      expect(tester.getRect(sq('a1')), a1);
      expect(app.state.currentProfile!.matchesPlayed, 1);
      await tester.tap(find.byKey(const Key('result-again')));
      await tester.pump();
      await tester.pump();
      expect(find.byType(MatchResultView), findsNothing);
      expect(app.speaker.spoken.last.$1, 'match.intro');
      expect(tester.getRect(sq('a1')), a1);
      // Resign again: a second finished match is recorded, the first only once.
      await tester.tap(find.byKey(const Key('match-resign')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('resign-yes')));
      await tester.pumpAndSettle();
      expect(app.state.currentProfile!.matchesPlayed, 2);
      await tester.pumpAndSettle();
    },
  );

  testWidgets('mate by the computer ends the match with consolation at once', (
    tester,
  ) async {
    final s = MatchSession(
      childColor: PieceColor.black,
      start: Position.fromFen('6k1/5ppp/8/8/8/8/8/R3K3 w - - 0 1'),
      random: Random(1),
    );
    await tester.pumpWidget(
      app.wrap(
        MatchScreen(
          session: s,
          thinkingDelay: const Duration(milliseconds: 100),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump();
    expect(s.result.outcome, GameOutcome.checkmate);
    expect(find.byType(MatchResultView), findsOneWidget);
    expect(find.byKey(const Key('result-icon-consolation')), findsOneWidget);
    expect(app.speaker.spoken.last.$1, 'match.lost');
    await tester.pumpAndSettle();
    expect(app.state.currentProfile!.matchStars, 1);
  });

  testWidgets('on a tall screen the result card sits above the board', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpResult(tester, resigned());
    final card = tester.getRect(
      find.byKey(const Key('result-icon-consolation')),
    );
    final board = tester.getRect(sq('a8'));
    expect(card.bottom, lessThanOrEqualTo(board.top));
    await tester.pumpAndSettle();
  });

  testWidgets('on a short screen the card lies over the board and closes', (
    tester,
  ) async {
    await pumpResult(tester, resigned());
    final card = tester.getRect(
      find.byKey(const Key('result-icon-consolation')),
    );
    final board = tester.getRect(sq('a8'));
    expect(card.top, greaterThan(board.top));
    await tester.tap(find.byKey(const Key('overlay-card')));
    await tester.pump();
    expect(find.byKey(const Key('result-icon-consolation')), findsNothing);
    await tester.pumpAndSettle();
  });
}
