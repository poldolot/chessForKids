import 'dart:io';

import 'package:chess_for_kids/data/app_repository.dart';
import 'package:chess_for_kids/data/models.dart';
import 'package:chess_for_kids/state/app_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory dir;
  late AppRepository repo;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('chess_state_');
    repo = AppRepository(dir);
  });

  tearDown(() => dir.delete(recursive: true));

  Future<AppState> loadWithProfile() async {
    final state = await AppState.load(repo);
    await state.createProfile(
      name: 'Zosia',
      theme: TeacherTheme.ufo,
      avatarIndex: 1,
    );
    return state;
  }

  test(
    'create, select and delete profiles keep lastProfileId consistent',
    () async {
      final state = await AppState.load(repo);
      expect(state.hasProfiles, isFalse);
      final a = await state.createProfile(
        name: 'A',
        theme: TeacherTheme.animals,
        avatarIndex: 1,
      );
      final b = await state.createProfile(
        name: 'B',
        theme: TeacherTheme.robots,
        avatarIndex: 2,
      );
      expect(a.id, isNot(b.id));
      expect(state.currentProfile?.id, b.id);
      await state.selectProfile(a.id);
      expect(state.currentProfile?.id, a.id);
      await state.deleteProfile(a.id);
      expect(state.currentProfile, isNull);
      expect(state.profiles.map((p) => p.id), [b.id]);
      expect((await repo.load()).lastProfileId, isNull);
      expect(() => state.selectProfile('nope'), throwsArgumentError);
    },
  );

  test('deleting another profile keeps the current one', () async {
    final state = await AppState.load(repo);
    final a = await state.createProfile(
      name: 'A',
      theme: TeacherTheme.animals,
      avatarIndex: 1,
    );
    final b = await state.createProfile(
      name: 'B',
      theme: TeacherTheme.robots,
      avatarIndex: 2,
    );
    await state.deleteProfile(a.id);
    expect(state.currentProfile?.id, b.id);
  });

  test('addStars keeps the best result, recordMatch accumulates', () async {
    final state = await loadWithProfile();
    await state.addStars('lesson:rook', 2);
    await state.addStars('lesson:rook', 1);
    expect(state.currentProfile!.stars['lesson:rook'], 2);
    await state.recordMatch(stars: 3, won: true);
    await state.recordMatch(stars: 1, won: false);
    final p = state.currentProfile!;
    expect(p.matchStars, 4);
    expect(p.matchesPlayed, 2);
    expect(p.matchesWon, 1);
    expect(p.totalStars, 6);
    expect((await repo.load()).lastProfile!.totalStars, 6);
  });

  test('resetProgress clears progress but keeps identity', () async {
    final state = await loadWithProfile();
    await state.addStars('lesson:rook', 3);
    await state.awardBadge('rook');
    await state.markLessonDone('rook');
    await state.recordMatch(stars: 2, won: true);
    await state.updateProfile(
      state.currentProfile!.copyWith(savedGameJson: '{}'),
    );
    await state.resetProgress(state.currentProfile!.id);
    final p = state.currentProfile!;
    expect(p.name, 'Zosia');
    expect(p.theme, TeacherTheme.ufo);
    expect(p.stars, isEmpty);
    expect(p.badges, isEmpty);
    expect(p.lessonsDone, isEmpty);
    expect(p.matchStars, 0);
    expect(p.matchesPlayed, 0);
    expect(p.savedGameJson, isNull);
  });

  test('updateSettings persists and notifies', () async {
    final state = await AppState.load(repo);
    var notified = 0;
    state.addListener(() => notified++);
    await state.updateSettings(state.settings.copyWith(languageCode: 'en'));
    expect(notified, 1);
    expect(state.settings.languageCode, 'en');
    expect((await repo.load()).settings.languageCode, 'en');
  });

  test('awardBadge and markLessonDone are idempotent', () async {
    final state = await loadWithProfile();
    await state.awardBadge('rook');
    await state.awardBadge('rook');
    await state.markLessonDone('rook');
    await state.markLessonDone('rook');
    expect(state.currentProfile!.badges, {'rook'});
    expect(state.currentProfile!.lessonsDone, {'rook'});
  });

  test('updateProfile replaces the profile with the same id', () async {
    final state = await loadWithProfile();
    final renamed = state.currentProfile!.copyWith(name: 'Ala', avatarIndex: 4);
    await state.updateProfile(renamed);
    expect(state.currentProfile, renamed);
    expect(state.profiles.length, 1);
  });

  test(
    'concurrent mutations are saved in order and leave a loadable file',
    () async {
      final state = await loadWithProfile();
      final futures = <Future<void>>[];
      for (var i = 1; i <= 10; i++) {
        futures.add(state.addStars('lesson:$i', i));
      }
      await Future.wait(futures);
      final loaded = await repo.load();
      expect(loaded.lastProfile!.stars.length, 10);
      expect(
        dir.listSync().map((e) => e.uri.pathSegments.last).toList()..sort(),
        ['app_state.json'],
      );
    },
  );

  test('recordMiniGame keeps the best stars and counts every win', () async {
    final state = await loadWithProfile();
    await state.recordMiniGame(key: 'game:rookRoads:0', stars: 3, won: true);
    await state.recordMiniGame(key: 'game:rookRoads:0', stars: 1, won: true);
    await state.recordMiniGame(key: 'game:pawnWar:0', stars: 1, won: false);
    final p = state.currentProfile!;
    expect(p.stars['game:rookRoads:0'], 3);
    expect(p.stars['game:pawnWar:0'], 1);
    expect(p.miniGameWins, 2);
  });

  test(
    'markGameIntroduced is idempotent and resetProgress clears game progress',
    () async {
      final state = await loadWithProfile();
      await state.markGameIntroduced('pawnWar');
      await state.markGameIntroduced('pawnWar');
      await state.recordMiniGame(key: 'game:pawnWar:0', stars: 2, won: true);
      expect(state.currentProfile!.introducedGames, {'pawnWar'});
      await state.resetProgress(state.currentProfile!.id);
      expect(state.currentProfile!.introducedGames, isEmpty);
      expect(state.currentProfile!.miniGameWins, 0);
    },
  );

  test('progress mutations without a current profile throw', () async {
    final state = await AppState.load(repo);
    expect(() => state.addStars('x', 1), throwsStateError);
  });

  test(
    'saveMatch stores and clears the saved game of the current profile',
    () async {
      final state = await loadWithProfile();
      await state.saveMatch('{"moves":["e2e4"]}');
      expect(state.currentProfile!.savedGameJson, '{"moves":["e2e4"]}');
      final reloaded = await AppState.load(repo);
      expect(reloaded.currentProfile!.savedGameJson, '{"moves":["e2e4"]}');
      await state.saveMatch(null);
      expect(state.currentProfile!.savedGameJson, isNull);
      expect((await AppState.load(repo)).currentProfile!.savedGameJson, isNull);
    },
  );
}
