import 'package:chess_for_kids/app/route_observer.dart';
import 'package:chess_for_kids/app/theme/app_theme.dart';
import 'package:chess_for_kids/core/speaker.dart';
import 'package:chess_for_kids/features/games/game_catalog.dart';
import 'package:chess_for_kids/features/games/game_model.dart';
import 'package:chess_for_kids/l10n/app_localizations.dart';
import 'package:chess_for_kids/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'memory_store.dart';

/// Test harness: in-memory store, fake speaker, game catalog, Polish locale,
/// palettes and the route observer.
final class TestApp {
  TestApp._(this.store, this.state, this.speaker, this.games);

  static Future<TestApp> create() async {
    // A blinking cursor keeps scheduling frames, so pumpAndSettle never settles.
    EditableText.debugDeterministicCursor = true;
    final store = MemoryStore();
    final state = await AppState.load(store);
    final games = await loadMiniGames(rootBundle);
    return TestApp._(store, state, FakeSpeaker(), games);
  }

  final MemoryStore store;
  final AppState state;
  final FakeSpeaker speaker;
  final List<MiniGame> games;

  Widget wrap(Widget home, {Locale locale = const Locale('pl')}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>.value(value: state),
        ChangeNotifierProvider<Speaker>.value(value: speaker),
        Provider<List<MiniGame>>.value(value: games),
      ],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: buildTheme(uiPaletteById('sky')),
        navigatorObservers: [appRouteObserver],
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
