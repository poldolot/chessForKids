import 'package:chess_for_kids/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('palette lookup falls back to defaults', () {
    expect(uiPaletteById('sky').id, 'sky');
    expect(uiPaletteById('nope').id, 'sky');
    expect(boardPaletteById('classic').id, 'classic');
    expect(boardPaletteById('nope').id, 'classic');
    expect(uiPalettes.map((p) => p.id).toSet().length, uiPalettes.length);
    expect(boardPalettes.map((p) => p.id).toSet().length, boardPalettes.length);
    expect(uiPalettes.length, greaterThanOrEqualTo(2));
    expect(boardPalettes.length, greaterThanOrEqualTo(3));
  });

  test('every ui palette keeps text readable on background and surface', () {
    for (final p in uiPalettes) {
      expect(
        contrastRatio(p.text, p.background),
        greaterThanOrEqualTo(4.5),
        reason: p.id,
      );
      expect(
        contrastRatio(p.text, p.surface),
        greaterThanOrEqualTo(4.5),
        reason: p.id,
      );
    }
  });

  test('board squares differ clearly in luminance', () {
    for (final p in boardPalettes) {
      expect(
        (p.light.computeLuminance() - p.dark.computeLuminance()).abs(),
        greaterThan(0.15),
        reason: p.id,
      );
    }
  });

  test('contrast ratio follows WCAG', () {
    expect(contrastRatio(Colors.black, Colors.white), closeTo(21, 0.01));
    expect(contrastRatio(Colors.white, Colors.black), closeTo(21, 0.01));
    expect(contrastRatio(Colors.white, Colors.white), closeTo(1, 0.01));
  });

  test('buildTheme applies the palette to the scaffold and buttons', () {
    final theme = buildTheme(uiPaletteById('sky'));
    expect(theme.scaffoldBackgroundColor, uiPaletteById('sky').background);
    expect(theme.useMaterial3, isTrue);
    expect(
      theme.filledButtonTheme.style?.minimumSize?.resolve({})?.height,
      greaterThanOrEqualTo(56),
    );
  });

  testWidgets('AppTheme.of exposes both palettes', (tester) async {
    late UiPalette ui;
    late BoardPalette board;
    await tester.pumpWidget(
      AppTheme(
        ui: uiPaletteById('sky'),
        board: boardPaletteById('classic'),
        child: Builder(
          builder: (context) {
            ui = AppTheme.of(context).ui;
            board = AppTheme.of(context).board;
            return const SizedBox();
          },
        ),
      ),
    );
    expect(ui.id, 'sky');
    expect(board.id, 'classic');
  });
}
