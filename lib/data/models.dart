import 'package:flutter/foundation.dart';

import '../core/speaker.dart';

/// Visual theme of the teachers and avatars.
enum TeacherTheme { animals, robots, ufo, vehicles }

/// Which color the child plays in a match.
enum ChildColor { white, random }

T _enumFromJson<T extends Enum>(List<T> values, Object? raw, String field) {
  for (final value in values) {
    if (value.name == raw) {
      return value;
    }
  }
  throw FormatException('Invalid $field', raw);
}

/// Device-wide settings managed in the parent zone.
@immutable
final class Settings {
  const Settings({
    this.languageCode,
    this.voiceEnabled = true,
    this.speechRate = SpeechRate.normal,
    this.uiPaletteId = 'sky',
    this.boardPaletteId = 'classic',
    this.childColor = ChildColor.white,
  });

  factory Settings.fromJson(Map<String, dynamic> json) {
    const defaults = Settings();
    return Settings(
      languageCode: json['languageCode'] as String?,
      voiceEnabled: json['voiceEnabled'] as bool? ?? defaults.voiceEnabled,
      speechRate: json['speechRate'] == null
          ? defaults.speechRate
          : _enumFromJson(SpeechRate.values, json['speechRate'], 'speechRate'),
      uiPaletteId: json['uiPaletteId'] as String? ?? defaults.uiPaletteId,
      boardPaletteId:
          json['boardPaletteId'] as String? ?? defaults.boardPaletteId,
      childColor: json['childColor'] == null
          ? defaults.childColor
          : _enumFromJson(ChildColor.values, json['childColor'], 'childColor'),
    );
  }

  /// `null` means "follow the system language".
  final String? languageCode;
  final bool voiceEnabled;
  final SpeechRate speechRate;
  final String uiPaletteId;
  final String boardPaletteId;
  final ChildColor childColor;

  Map<String, dynamic> toJson() => {
    'languageCode': languageCode,
    'voiceEnabled': voiceEnabled,
    'speechRate': speechRate.name,
    'uiPaletteId': uiPaletteId,
    'boardPaletteId': boardPaletteId,
    'childColor': childColor.name,
  };

  Settings copyWith({
    String? languageCode,
    bool clearLanguage = false,
    bool? voiceEnabled,
    SpeechRate? speechRate,
    String? uiPaletteId,
    String? boardPaletteId,
    ChildColor? childColor,
  }) {
    return Settings(
      languageCode: clearLanguage ? null : (languageCode ?? this.languageCode),
      voiceEnabled: voiceEnabled ?? this.voiceEnabled,
      speechRate: speechRate ?? this.speechRate,
      uiPaletteId: uiPaletteId ?? this.uiPaletteId,
      boardPaletteId: boardPaletteId ?? this.boardPaletteId,
      childColor: childColor ?? this.childColor,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Settings &&
      other.languageCode == languageCode &&
      other.voiceEnabled == voiceEnabled &&
      other.speechRate == speechRate &&
      other.uiPaletteId == uiPaletteId &&
      other.boardPaletteId == boardPaletteId &&
      other.childColor == childColor;

  @override
  int get hashCode => Object.hash(
    languageCode,
    voiceEnabled,
    speechRate,
    uiPaletteId,
    boardPaletteId,
    childColor,
  );
}

/// One child's identity and progress.
@immutable
final class Profile {
  const Profile({
    required this.id,
    required this.name,
    required this.theme,
    required this.avatarIndex,
    this.stars = const {},
    this.badges = const {},
    this.lessonsDone = const {},
    this.matchStars = 0,
    this.matchesPlayed = 0,
    this.matchesWon = 0,
    this.unlockAllMiniGames = false,
    this.savedGameJson,
    this.miniGameWins = 0,
    this.introducedGames = const {},
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    final avatarIndex = json['avatarIndex'];
    if (id is! String || name is! String || avatarIndex is! int) {
      throw FormatException('Profile is missing required fields', json);
    }
    return Profile(
      id: id,
      name: name,
      theme: _enumFromJson(TeacherTheme.values, json['theme'], 'theme'),
      avatarIndex: avatarIndex,
      stars: (json['stars'] as Map<String, dynamic>? ?? const {}).map(
        (k, v) => MapEntry(k, v as int),
      ),
      badges: (json['badges'] as List<dynamic>? ?? const [])
          .cast<String>()
          .toSet(),
      lessonsDone: (json['lessonsDone'] as List<dynamic>? ?? const [])
          .cast<String>()
          .toSet(),
      matchStars: json['matchStars'] as int? ?? 0,
      matchesPlayed: json['matchesPlayed'] as int? ?? 0,
      matchesWon: json['matchesWon'] as int? ?? 0,
      unlockAllMiniGames: json['unlockAllMiniGames'] as bool? ?? false,
      savedGameJson: json['savedGameJson'] as String?,
      miniGameWins: json['miniGameWins'] as int? ?? 0,
      introducedGames: (json['introducedGames'] as List<dynamic>? ?? const [])
          .cast<String>()
          .toSet(),
    );
  }

  final String id;
  final String name;
  final TeacherTheme theme;

  /// 1-based index of the avatar within [theme].
  final int avatarIndex;

  /// Best star result per lesson or mini-game board key.
  final Map<String, int> stars;
  final Set<String> badges;
  final Set<String> lessonsDone;

  /// Stars from finished matches, accumulated.
  final int matchStars;
  final int matchesPlayed;
  final int matchesWon;
  final bool unlockAllMiniGames;

  /// A match in progress, serialized by the match feature.
  final String? savedGameJson;

  /// Mini-game boards won or finished.
  final int miniGameWins;

  /// Games whose spoken introduction the child has already heard.
  final Set<String> introducedGames;

  int get totalStars => stars.values.fold(0, (a, b) => a + b) + matchStars;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'theme': theme.name,
    'avatarIndex': avatarIndex,
    'stars': stars,
    'badges': badges.toList(),
    'lessonsDone': lessonsDone.toList(),
    'matchStars': matchStars,
    'matchesPlayed': matchesPlayed,
    'matchesWon': matchesWon,
    'unlockAllMiniGames': unlockAllMiniGames,
    'savedGameJson': savedGameJson,
    'miniGameWins': miniGameWins,
    'introducedGames': introducedGames.toList(),
  };

  Profile copyWith({
    String? name,
    TeacherTheme? theme,
    int? avatarIndex,
    Map<String, int>? stars,
    Set<String>? badges,
    Set<String>? lessonsDone,
    int? matchStars,
    int? matchesPlayed,
    int? matchesWon,
    bool? unlockAllMiniGames,
    String? savedGameJson,
    bool clearSavedGame = false,
    int? miniGameWins,
    Set<String>? introducedGames,
  }) {
    return Profile(
      id: id,
      name: name ?? this.name,
      theme: theme ?? this.theme,
      avatarIndex: avatarIndex ?? this.avatarIndex,
      stars: stars ?? this.stars,
      badges: badges ?? this.badges,
      lessonsDone: lessonsDone ?? this.lessonsDone,
      matchStars: matchStars ?? this.matchStars,
      matchesPlayed: matchesPlayed ?? this.matchesPlayed,
      matchesWon: matchesWon ?? this.matchesWon,
      unlockAllMiniGames: unlockAllMiniGames ?? this.unlockAllMiniGames,
      savedGameJson: clearSavedGame
          ? null
          : (savedGameJson ?? this.savedGameJson),
      miniGameWins: miniGameWins ?? this.miniGameWins,
      introducedGames: introducedGames ?? this.introducedGames,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Profile &&
      other.id == id &&
      other.name == name &&
      other.theme == theme &&
      other.avatarIndex == avatarIndex &&
      mapEquals(other.stars, stars) &&
      setEquals(other.badges, badges) &&
      setEquals(other.lessonsDone, lessonsDone) &&
      other.matchStars == matchStars &&
      other.matchesPlayed == matchesPlayed &&
      other.matchesWon == matchesWon &&
      other.unlockAllMiniGames == unlockAllMiniGames &&
      other.savedGameJson == savedGameJson &&
      other.miniGameWins == miniGameWins &&
      setEquals(other.introducedGames, introducedGames);

  @override
  int get hashCode => Object.hash(
    id,
    name,
    theme,
    avatarIndex,
    matchStars,
    matchesPlayed,
    matchesWon,
    unlockAllMiniGames,
    savedGameJson,
    miniGameWins,
  );
}

/// Everything the app persists.
@immutable
final class AppData {
  const AppData({
    this.version = currentVersion,
    this.settings = const Settings(),
    this.profiles = const [],
    this.lastProfileId,
  });

  factory AppData.fromJson(Map<String, dynamic> json) {
    final version = json['version'] as int? ?? currentVersion;
    if (version > currentVersion) {
      throw FormatException('Unsupported data version $version', json);
    }
    return AppData(
      version: currentVersion,
      settings: Settings.fromJson(
        json['settings'] as Map<String, dynamic>? ?? const {},
      ),
      profiles: (json['profiles'] as List<dynamic>? ?? const [])
          .map((p) => Profile.fromJson(p as Map<String, dynamic>))
          .toList(),
      lastProfileId: json['lastProfileId'] as String?,
    );
  }

  static const int currentVersion = 1;

  final int version;
  final Settings settings;
  final List<Profile> profiles;
  final String? lastProfileId;

  /// The profile named by [lastProfileId], or `null` when it does not exist.
  Profile? get lastProfile {
    for (final profile in profiles) {
      if (profile.id == lastProfileId) {
        return profile;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
    'version': version,
    'settings': settings.toJson(),
    'profiles': profiles.map((p) => p.toJson()).toList(),
    'lastProfileId': lastProfileId,
  };

  AppData copyWith({
    Settings? settings,
    List<Profile>? profiles,
    String? lastProfileId,
    bool clearLastProfile = false,
  }) {
    return AppData(
      version: version,
      settings: settings ?? this.settings,
      profiles: profiles ?? this.profiles,
      lastProfileId: clearLastProfile
          ? null
          : (lastProfileId ?? this.lastProfileId),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AppData &&
      other.version == version &&
      other.settings == settings &&
      listEquals(other.profiles, profiles) &&
      other.lastProfileId == lastProfileId;

  @override
  int get hashCode =>
      Object.hash(version, settings, Object.hashAll(profiles), lastProfileId);
}
