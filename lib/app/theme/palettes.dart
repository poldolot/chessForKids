import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Colors of the app chrome: backgrounds, text and the three section tiles.
@immutable
final class UiPalette {
  const UiPalette({
    required this.id,
    required this.background,
    required this.surface,
    required this.text,
    required this.muted,
    required this.accent,
    required this.accentDeep,
    required this.learn,
    required this.games,
    required this.play,
  });

  final String id;
  final Color background;
  final Color surface;
  final Color text;
  final Color muted;
  final Color accent;
  final Color accentDeep;
  final Color learn;
  final Color games;
  final Color play;
}

/// Colors of the chessboard and its highlights.
@immutable
final class BoardPalette {
  const BoardPalette({
    required this.id,
    required this.light,
    required this.dark,
    required this.selected,
    required this.moveDot,
    required this.capture,
    required this.check,
    required this.lastMove,
  });

  final String id;
  final Color light;
  final Color dark;
  final Color selected;
  final Color moveDot;
  final Color capture;
  final Color check;
  final Color lastMove;
}

const List<UiPalette> uiPalettes = [
  UiPalette(
    id: 'sky',
    background: Color(0xFFE7F4FB),
    surface: Color(0xFFFFFFFF),
    text: Color(0xFF2B3A4A),
    muted: Color(0xFF5B6B7A),
    accent: Color(0xFFFFD166),
    accentDeep: Color(0xFFF4A300),
    learn: Color(0xFFFFD166),
    games: Color(0xFF8FBF9F),
    play: Color(0xFFF8B4A0),
  ),
  UiPalette(
    id: 'meadow',
    background: Color(0xFFEDF6E8),
    surface: Color(0xFFFFFFFF),
    text: Color(0xFF26392B),
    muted: Color(0xFF5A6E5F),
    accent: Color(0xFFF6C84C),
    accentDeep: Color(0xFFD9962A),
    learn: Color(0xFFF6C84C),
    games: Color(0xFF9CCB8A),
    play: Color(0xFFF2A68B),
  ),
  UiPalette(
    id: 'sunset',
    background: Color(0xFFFBEFE6),
    surface: Color(0xFFFFFAF6),
    text: Color(0xFF3B2F2F),
    muted: Color(0xFF75615E),
    accent: Color(0xFFFFB86B),
    accentDeep: Color(0xFFE07A1F),
    learn: Color(0xFFFFC978),
    games: Color(0xFF9BC9B4),
    play: Color(0xFFF49C8E),
  ),
];

const List<BoardPalette> boardPalettes = [
  BoardPalette(
    id: 'classic',
    light: Color(0xFFF6ECD4),
    dark: Color(0xFF8FBF9F),
    selected: Color(0xFFF4A300),
    moveDot: Color(0xD9F4A300),
    capture: Color(0xFFFF8A65),
    check: Color(0xFFE53935),
    lastMove: Color(0xFFFFE79A),
  ),
  BoardPalette(
    id: 'wood',
    light: Color(0xFFF0D9B5),
    dark: Color(0xFFB58863),
    selected: Color(0xFFF4A300),
    moveDot: Color(0xD9F4A300),
    capture: Color(0xFFE5533D),
    check: Color(0xFFD32F2F),
    lastMove: Color(0xFFF7EC74),
  ),
  BoardPalette(
    id: 'ocean',
    light: Color(0xFFE3F0F7),
    dark: Color(0xFF6FA3C7),
    selected: Color(0xFFFFB300),
    moveDot: Color(0xD9FFB300),
    capture: Color(0xFFFF7043),
    check: Color(0xFFE53935),
    lastMove: Color(0xFFFFF59D),
  ),
  BoardPalette(
    id: 'candy',
    light: Color(0xFFFFF0F5),
    dark: Color(0xFFD98BB5),
    selected: Color(0xFFFFB300),
    moveDot: Color(0xD9FFB300),
    capture: Color(0xFFFF7043),
    check: Color(0xFFE53935),
    lastMove: Color(0xFFFFF59D),
  ),
];

UiPalette uiPaletteById(String id) =>
    uiPalettes.firstWhere((p) => p.id == id, orElse: () => uiPalettes.first);

BoardPalette boardPaletteById(String id) => boardPalettes.firstWhere(
  (p) => p.id == id,
  orElse: () => boardPalettes.first,
);

/// WCAG 2 contrast ratio between two colors (1..21).
double contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}
