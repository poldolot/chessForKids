import 'dart:math';

import 'package:chess_for_kids/ai/ai.dart';
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
  const delay = Duration(milliseconds: 300);

  setUp(() async {
    app = await TestApp.create();
    await app.state.createProfile(
      name: 'Zosia',
      theme: TeacherTheme.robots,
      avatarIndex: 1,
    );
  });

  Finder sq(String name) => find.byKey(Key('sq-$name'));
  Finder pieceOn(String name) =>
      find.descendant(of: sq(name), matching: find.byType(PieceImage));
  Square at(String name) => Square.parse(name);

  Future<MatchSession> pumpMatch(
    WidgetTester tester, {
    MatchSession? session,
  }) async {
    final s =
        session ??
        MatchSession(childColor: PieceColor.white, random: Random(1));
    await tester.pumpWidget(
      app.wrap(
        MatchScreen(session: s, thinkingDelay: delay, random: Random(1)),
      ),
    );
    await tester.pump();
    await tester.pump();
    return s;
  }

  Future<void> tapMove(WidgetTester tester, String from, String to) async {
    await tester.tap(sq(from));
    await tester.pump();
    await tester.tap(sq(to));
    await tester.pump();
  }

  Future<void> letComputerMove(WidgetTester tester) async {
    await tester.pump(delay);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
  }

  testWidgets('the intro is spoken once and the child moves first', (
    tester,
  ) async {
    await pumpMatch(tester);
    expect(app.speaker.spoken.where((s) => s.$1 == 'match.intro').length, 1);
    expect(find.byKey(const Key('thinking')), findsNothing);
    await tester.tap(sq('e2'));
    await tester.pump();
    expect(find.byKey(const Key('move-dot')), findsWidgets);
    await tester.pumpAndSettle();
  });

  testWidgets('a child move is saved, the computer thinks, then replies once', (
    tester,
  ) async {
    final s = await pumpMatch(tester);
    await tapMove(tester, 'e2', 'e4');
    expect(app.state.currentProfile!.savedGameJson, contains('"e2e4"'));
    expect(find.byKey(const Key('thinking')), findsOneWidget);
    await tester.tap(sq('d2'));
    await tester.pump();
    expect(find.byKey(const Key('move-dot')), findsNothing);
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('match-hint')))
          .onPressed,
      isNull,
    );
    await letComputerMove(tester);
    await tester.pump(delay);
    await tester.pump();
    expect(s.toJson()['moves'], hasLength(2));
    expect(
      app.state.currentProfile!.savedGameJson,
      contains('"moves":["e2e4","'),
    );
    expect(find.byKey(const Key('thinking')), findsNothing);
    expect(s.childToMove, isTrue);
    await tester.pumpAndSettle();
  });

  testWidgets('a computer check is announced', (tester) async {
    // White's only legal move is Rxb1, which checks the king on b8.
    final s = MatchSession(
      childColor: PieceColor.black,
      start: Position.fromFen('1k6/8/8/8/4b3/8/8/Kq5R w - - 0 1'),
      random: Random(1),
    );
    await pumpMatch(tester, session: s);
    expect(app.speaker.spoken.last.$1, 'match.introBlack');
    expect(find.byKey(const Key('thinking')), findsOneWidget);
    await letComputerMove(tester);
    expect(s.lastMove, Move.parseUci('h1b1'));
    expect(app.speaker.spoken.last.$1, 'match.check');
    expect(app.speaker.nonInterrupting, isNot(contains('match.check')));
    expect(find.byKey(Key('check-${at('b8').name}')), findsOneWidget);
    // After the child's reply the bubble shows the thinking line, so a
    // second check is a text change again and gets spoken again.
    final spokenBefore = app.speaker.spoken.length;
    await tapMove(tester, 'b8', 'c7');
    expect(find.text('Myślę…'), findsOneWidget);
    expect(app.speaker.spoken.length, spokenBefore);
    await tester.pumpAndSettle();
  });

  testWidgets('the hint highlights a move and speaks without interrupting', (
    tester,
  ) async {
    await pumpMatch(tester);
    await tester.tap(find.byKey(const Key('match-hint')));
    await tester.pump();
    expect(find.byKey(const Key('selected-frame')), findsOneWidget);
    expect(find.byKey(const Key('move-dot')), findsOneWidget);
    expect(app.speaker.spoken.last.$1, 'match.hint');
    expect(app.speaker.nonInterrupting, contains('match.hint'));
    await tester.pump(const Duration(milliseconds: 2100));
    expect(find.byKey(const Key('selected-frame')), findsNothing);
    await tester.pumpAndSettle();
  });

  testWidgets('undo takes back the pair of moves', (tester) async {
    final s = await pumpMatch(tester);
    await tapMove(tester, 'e2', 'e4');
    await letComputerMove(tester);
    await tester.tap(find.byKey(const Key('match-undo')));
    await tester.pump();
    expect(s.position, Position.initial());
    expect(pieceOn('e2'), findsOneWidget);
    expect(app.state.currentProfile!.savedGameJson, contains('"moves":[]'));
    await tester.pumpAndSettle();
  });

  testWidgets('undo while the computer thinks cancels its move', (
    tester,
  ) async {
    final s = await pumpMatch(tester);
    await tapMove(tester, 'e2', 'e4');
    expect(find.byKey(const Key('thinking')), findsOneWidget);
    await tester.tap(find.byKey(const Key('match-undo')));
    await tester.pump();
    expect(s.position, Position.initial());
    await tester.pump(delay * 2);
    await tester.pump();
    expect(s.position, Position.initial());
    expect(find.byKey(const Key('thinking')), findsNothing);
    await tester.pumpAndSettle();
  });

  testWidgets('resigning asks first; no keeps playing, yes ends the match', (
    tester,
  ) async {
    final s = await pumpMatch(tester);
    await tester.tap(find.byKey(const Key('match-resign')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('resign-no')));
    await tester.pumpAndSettle();
    expect(s.result.isOver, isFalse);
    expect(find.byKey(const Key('match-result')), findsNothing);
    await tester.tap(find.byKey(const Key('match-resign')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('resign-yes')));
    await tester.pumpAndSettle();
    expect(s.result.outcome, GameOutcome.resignation);
    expect(find.byKey(const Key('match-result')), findsOneWidget);
  });

  testWidgets('promotion waits for the picker, then the computer replies', (
    tester,
  ) async {
    final s = MatchSession(
      childColor: PieceColor.white,
      start: Position.fromFen('8/P3k3/8/8/8/8/8/4K3 w - - 0 1'),
      random: Random(1),
    );
    await pumpMatch(tester, session: s);
    await tapMove(tester, 'a7', 'a8');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('promote-q')), findsOneWidget);
    expect(s.position.pieceAt(at('a7'))?.type, PieceType.pawn);
    await tester.tap(find.byKey(const Key('promote-q')));
    await tester.pump();
    await tester.pump();
    expect(s.position.pieceAt(at('a8'))?.type, PieceType.queen);
    await letComputerMove(tester);
    expect(s.toJson()['moves'], ['a7a8q', isA<String>()]);
    await tester.pumpAndSettle();
  });

  testWidgets('a black child sees the board from the black side', (
    tester,
  ) async {
    final s = MatchSession(childColor: PieceColor.black, random: Random(1));
    await pumpMatch(tester, session: s);
    expect(
      tester.getTopLeft(sq('a8')).dy,
      greaterThan(tester.getTopLeft(sq('a1')).dy),
    );
    expect(app.speaker.spoken.last.$1, 'match.introBlack');
    await letComputerMove(tester);
    expect(s.childToMove, isTrue);
    expect(app.speaker.spoken.last.$1, 'match.yourMove');
    expect(app.speaker.nonInterrupting, contains('match.yourMove'));
    await tester.pumpAndSettle();
  });

  testWidgets('a 360x640 phone fits the match screen', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpMatch(tester);
    expect(tester.takeException(), isNull);
    await tapMove(tester, 'e2', 'e4');
    expect(tester.takeException(), isNull);
    await tester.pumpAndSettle();
  });

  testWidgets('a new match uses the level chosen for the profile', (
    tester,
  ) async {
    await app.state.updateProfile(
      app.state.currentProfile!.copyWith(matchLevel: MatchLevel.veryEasy),
    );
    await tester.pumpWidget(
      app.wrap(MatchScreen(thinkingDelay: delay, random: Random(1))),
    );
    await tester.pump();
    await tester.pump();
    await tapMove(tester, 'e2', 'e4');
    expect(
      app.state.currentProfile!.savedGameJson,
      contains('"level":"veryEasy"'),
    );
    await tester.pumpAndSettle();
  });

  testWidgets('after castling the computer waits for the animation', (
    tester,
  ) async {
    final s = MatchSession(
      childColor: PieceColor.white,
      start: Position.fromFen('4k3/8/8/8/8/8/8/4K2R w K - 0 1'),
      random: Random(1),
    );
    await pumpMatch(tester, session: s);
    await tapMove(tester, 'e1', 'g1');
    expect(s.toJson()['moves'], ['e1g1']);
    await tester.pump(const Duration(milliseconds: 600));
    expect(s.toJson()['moves'], hasLength(1));
    await tester.pump(const Duration(milliseconds: 600));
    expect(s.toJson()['moves'], hasLength(2));
    await tester.pumpAndSettle();
  });
}
