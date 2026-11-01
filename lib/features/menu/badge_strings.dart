import '../../l10n/app_localizations.dart';

/// Name of badge [id] (ids as in `kBadgeIds`).
String badgeName(AppLocalizations l10n, String id) => switch (id) {
  'pawn' => l10n.badgePawnName,
  'rook' => l10n.badgeRookName,
  'bishop' => l10n.badgeBishopName,
  'queen' => l10n.badgeQueenName,
  'king' => l10n.badgeKingName,
  'knight' => l10n.badgeKnightName,
  'chessPlayer' => l10n.badgeChessPlayerName,
  'firstMatch' => l10n.badgeFirstMatchName,
  'firstWin' => l10n.badgeFirstWinName,
  'persistent' => l10n.badgePersistentName,
  'hunter' => l10n.badgeHunterName,
  'collector' => l10n.badgeCollectorName,
  _ => throw ArgumentError.value(id, 'id', 'Unknown badge'),
};

/// What badge [id] is awarded for, one short sentence.
String badgeDescription(AppLocalizations l10n, String id) => switch (id) {
  'pawn' => l10n.badgePawnDesc,
  'rook' => l10n.badgeRookDesc,
  'bishop' => l10n.badgeBishopDesc,
  'queen' => l10n.badgeQueenDesc,
  'king' => l10n.badgeKingDesc,
  'knight' => l10n.badgeKnightDesc,
  'chessPlayer' => l10n.badgeChessPlayerDesc,
  'firstMatch' => l10n.badgeFirstMatchDesc,
  'firstWin' => l10n.badgeFirstWinDesc,
  'persistent' => l10n.badgePersistentDesc,
  'hunter' => l10n.badgeHunterDesc,
  'collector' => l10n.badgeCollectorDesc,
  _ => throw ArgumentError.value(id, 'id', 'Unknown badge'),
};

/// The spoken line for a badge: its name, then what it is for.
String badgeLine(AppLocalizations l10n, String id) =>
    '${badgeName(l10n, id)}. ${badgeDescription(l10n, id)}';
