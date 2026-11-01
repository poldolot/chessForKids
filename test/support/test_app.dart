import 'package:chess_for_kids/app/theme/app_theme.dart';
import 'package:chess_for_kids/core/speaker.dart';
import 'package:chess_for_kids/l10n/app_localizations.dart';
import 'package:chess_for_kids/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'memory_store.dart';

/// Test harness: in-memory store, fake speaker, Polish locale, palettes.
final class TestApp {
  TestApp._(this.store, this.state, this.speaker);

  static Future<TestApp> create() async {
    // A blinking cursor keeps scheduling frames, so pumpAndSettle never settles.
    EditableText.debugDeterministicCursor = true;
    final store = MemoryStore();
    final state = await AppState.load(store);
    return TestApp._(store, state, FakeSpeaker());
  }

  final MemoryStore store;
  final AppState state;
  final FakeSpeaker speaker;

  Widget wrap(Widget home, {Locale locale = const Locale('pl')}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>.value(value: state),
        ChangeNotifierProvider<Speaker>.value(value: speaker),
      ],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: buildTheme(uiPaletteById('sky')),
        builder: (context, child) => AppTheme(
          ui: uiPaletteById('sky'),
          board: boardPaletteById('classic'),
          child: child!,
        ),
        home: home,
      ),
    );
  }
}
