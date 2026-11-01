import 'package:flutter/material.dart';

import '../constants.dart';
import 'palettes.dart';

export 'palettes.dart';

/// Material theme derived from a [UiPalette]: big rounded controls that a
/// child can hit, colors from the palette.
ThemeData buildTheme(UiPalette p) {
  final scheme = ColorScheme.fromSeed(
    seedColor: p.accent,
    primary: p.accentDeep,
    surface: p.surface,
    onSurface: p.text,
  );
  const shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(22)),
  );
  const minSize = Size(kMinTouchTarget, kMinTouchTarget);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: p.background,
    textTheme: Typography.blackMountainView.apply(
      bodyColor: p.text,
      displayColor: p.text,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: minSize,
        shape: shape,
        backgroundColor: p.accent,
        foregroundColor: p.text,
        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(minimumSize: minSize, shape: shape),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(minimumSize: minSize),
    ),
    cardTheme: CardThemeData(color: p.surface, shape: shape, elevation: 0),
    dialogTheme: DialogThemeData(backgroundColor: p.surface, shape: shape),
  );
}

/// Makes the active palettes available below it in the tree.
class AppTheme extends InheritedWidget {
  const AppTheme({
    super.key,
    required this.ui,
    required this.board,
    required super.child,
  });

  final UiPalette ui;
  final BoardPalette board;

  static AppTheme of(BuildContext context) {
    final theme = context.dependOnInheritedWidgetOfExactType<AppTheme>();
    assert(theme != null, 'No AppTheme found above this widget');
    return theme!;
  }

  @override
  bool updateShouldNotify(AppTheme oldWidget) =>
      oldWidget.ui != ui || oldWidget.board != board;
}
