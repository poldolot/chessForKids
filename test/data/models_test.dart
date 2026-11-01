import 'dart:convert';

import 'package:chess_for_kids/core/speaker.dart';
import 'package:chess_for_kids/data/models.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> roundTrip(Map<String, dynamic> json) =>
    jsonDecode(jsonEncode(json)) as Map<String, dynamic>;

void main() {
  test('settings round-trip through json with defaults', () {
    const s = Settings(
      languageCode: 'pl',
      voiceEnabled: false,
      speechRate: SpeechRate.slow,
      boardPaletteId: 'wood',
    );
    expect(Settings.fromJson(roundTrip(s.toJson())), s);
    expect(Settings.fromJson(const {}), const Settings());
    expect(const Settings().uiPaletteId, 'sky');
    expect(const Settings().childColor, ChildColor.white);
    expect(s.copyWith(languageCode: 'en').languageCode, 'en');
    expect(s.copyWith(clearLanguage: true).languageCode, isNull);
  });

  test('profile round-trip keeps progress and computes total stars', () {
    const p = Profile(
      id: 'p1',
      name: 'Zosia',
      theme: TeacherTheme.robots,
      avatarIndex: 2,
      stars: {'lesson:rook': 3, 'game:pawnwar:1': 2},
      badges: {'rook'},
      lessonsDone: {'pawn', 'rook'},
      matchStars: 4,
      matchesPlayed: 2,
      matchesWon: 1,
      unlockAllMiniGames: true,
      savedGameJson: '{"x":1}',
    );
    final back = Profile.fromJson(roundTrip(p.toJson()));
    expect(back, p);
    expect(back.totalStars, 9);
    expect(back.copyWith(name: 'Ala').name, 'Ala');
    expect(back.copyWith(clearSavedGame: true).savedGameJson, isNull);
  });

  test('app data round-trip and lastProfile lookup', () {
    const data = AppData(
      profiles: [
        Profile(id: 'a', name: '', theme: TeacherTheme.animals, avatarIndex: 1),
      ],
      lastProfileId: 'a',
    );
    final back = AppData.fromJson(roundTrip(data.toJson()));
    expect(back, data);
    expect(back.lastProfile?.id, 'a');
    expect(back.copyWith(lastProfileId: 'zzz').lastProfile, isNull);
    expect(back.copyWith(clearLastProfile: true).lastProfileId, isNull);
    expect(back.toJson()['version'], 1);
  });

  test('mini-game wins and introductions round-trip and default to empty', () {
    const p = Profile(
      id: 'p',
      name: '',
      theme: TeacherTheme.animals,
      avatarIndex: 1,
      miniGameWins: 4,
      introducedGames: {'pawnWar'},
    );
    expect(Profile.fromJson(roundTrip(p.toJson())), p);
    final old = Profile.fromJson(const {
      'id': 'x',
      'name': '',
      'theme': 'ufo',
      'avatarIndex': 4,
    });
    expect(old.miniGameWins, 0);
    expect(old.introducedGames, isEmpty);
  });

  test('newer version is rejected, missing fields fall back to defaults', () {
    expect(
      () => AppData.fromJson(const {'version': 99}),
      throwsFormatException,
    );
    expect(AppData.fromJson(const {'version': 1}).profiles, isEmpty);
    expect(AppData.fromJson(const {}).settings, const Settings());
    expect(() => Profile.fromJson(const {'id': 'x'}), throwsFormatException);
    expect(
      Profile.fromJson(const {
        'id': 'x',
        'name': '',
        'theme': 'ufo',
        'avatarIndex': 4,
      }).stars,
      isEmpty,
    );
    expect(
      () => Profile.fromJson(const {
        'id': 'x',
        'name': '',
        'theme': 'dragons',
        'avatarIndex': 1,
      }),
      throwsFormatException,
    );
  });
}
