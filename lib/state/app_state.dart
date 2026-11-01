import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/app_store.dart';
import '../data/models.dart';

/// The single source of truth for settings, profiles and progress.
///
/// Every mutation updates [data], notifies listeners and persists through the
/// repository before completing.
final class AppState extends ChangeNotifier {
  AppState(this._store, [AppData data = const AppData()]) : _data = data;

  static Future<AppState> load(AppStore store) async =>
      AppState(store, await store.load());

  final AppStore _store;
  AppData _data;
  int _idCounter = 0;
  bool _saving = false;
  bool _dirty = false;
  Completer<void>? _idle;

  AppData get data => _data;
  Settings get settings => _data.settings;
  List<Profile> get profiles => _data.profiles;
  Profile? get currentProfile => _data.lastProfile;
  bool get hasProfiles => _data.profiles.isNotEmpty;

  Future<Profile> createProfile({
    required String name,
    required TeacherTheme theme,
    required int avatarIndex,
  }) async {
    final profile = Profile(
      id: '${DateTime.now().millisecondsSinceEpoch}-${_idCounter++}',
      name: name,
      theme: theme,
      avatarIndex: avatarIndex,
    );
    await _commit(
      _data.copyWith(
        profiles: [..._data.profiles, profile],
        lastProfileId: profile.id,
      ),
    );
    return profile;
  }

  Future<void> selectProfile(String id) async {
    if (!_data.profiles.any((p) => p.id == id)) {
      throw ArgumentError.value(id, 'id', 'No such profile');
    }
    await _commit(_data.copyWith(lastProfileId: id));
  }

  /// Leaves the profile picker without a selected profile.
  Future<void> deselectProfile() =>
      _commit(_data.copyWith(clearLastProfile: true));

  Future<void> updateProfile(Profile profile) async {
    await _commit(
      _data.copyWith(
        profiles: [
          for (final p in _data.profiles) p.id == profile.id ? profile : p,
        ],
      ),
    );
  }

  Future<void> deleteProfile(String id) async {
    final remaining = _data.profiles.where((p) => p.id != id).toList();
    await _commit(
      _data.copyWith(
        profiles: remaining,
        clearLastProfile: _data.lastProfileId == id,
      ),
    );
  }

  Future<void> resetProgress(String id) async {
    final profile = _data.profiles.firstWhere((p) => p.id == id);
    await updateProfile(
      Profile(
        id: profile.id,
        name: profile.name,
        theme: profile.theme,
        avatarIndex: profile.avatarIndex,
        unlockAllMiniGames: profile.unlockAllMiniGames,
      ),
    );
  }

  Future<void> updateSettings(Settings settings) =>
      _commit(_data.copyWith(settings: settings));

  /// Records the best star result for a lesson or mini-game board.
  Future<void> addStars(String key, int stars) async {
    final profile = _requireProfile();
    final best = profile.stars[key] ?? 0;
    if (stars <= best) {
      return;
    }
    await updateProfile(
      profile.copyWith(stars: {...profile.stars, key: stars}),
    );
  }

  Future<void> recordMatch({required int stars, required bool won}) async {
    final profile = _requireProfile();
    await updateProfile(
      profile.copyWith(
        matchStars: profile.matchStars + stars,
        matchesPlayed: profile.matchesPlayed + 1,
        matchesWon: profile.matchesWon + (won ? 1 : 0),
      ),
    );
  }

  /// Records a finished mini-game board: best stars per key, every win counted.
  Future<void> recordMiniGame({
    required String key,
    required int stars,
    required bool won,
  }) async {
    final profile = _requireProfile();
    final best = profile.stars[key] ?? 0;
    await updateProfile(
      profile.copyWith(
        stars: stars > best ? {...profile.stars, key: stars} : null,
        miniGameWins: profile.miniGameWins + (won ? 1 : 0),
      ),
    );
  }

  /// Stores the match in progress of the current profile; `null` clears it.
  Future<void> saveMatch(String? json) async {
    final profile = _requireProfile();
    if (profile.savedGameJson == json) {
      return;
    }
    await updateProfile(
      profile.copyWith(savedGameJson: json, clearSavedGame: json == null),
    );
  }

  /// Remembers that the child has heard a game's introduction.
  Future<void> markGameIntroduced(String gameId) async {
    final profile = _requireProfile();
    if (profile.introducedGames.contains(gameId)) {
      return;
    }
    await updateProfile(
      profile.copyWith(introducedGames: {...profile.introducedGames, gameId}),
    );
  }

  Future<void> awardBadge(String id) async {
    final profile = _requireProfile();
    if (profile.badges.contains(id)) {
      return;
    }
    await updateProfile(profile.copyWith(badges: {...profile.badges, id}));
  }

  Future<void> markLessonDone(String id) async {
    final profile = _requireProfile();
    if (profile.lessonsDone.contains(id)) {
      return;
    }
    await updateProfile(
      profile.copyWith(lessonsDone: {...profile.lessonsDone, id}),
    );
  }

  Profile _requireProfile() {
    final profile = currentProfile;
    if (profile == null) {
      throw StateError('No profile selected');
    }
    return profile;
  }

  /// Applies [data], notifies, and persists.
  ///
  /// Writes never overlap: while one save is in flight, further commits only
  /// mark the state dirty and the running loop writes the newest data once
  /// more. Every caller's future completes when the file holds its data.
  Future<void> _commit(AppData data) {
    _data = data;
    notifyListeners();
    _dirty = true;
    if (_saving) {
      return _idle!.future;
    }
    return _drain();
  }

  Future<void> _drain() async {
    _saving = true;
    final idle = _idle = Completer<void>();
    try {
      while (_dirty) {
        _dirty = false;
        await _store.save(_data);
      }
    } finally {
      _saving = false;
      idle.complete();
    }
  }
}
