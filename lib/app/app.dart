import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/speaker.dart';
import '../features/menu/coming_soon_screen.dart';
import '../features/menu/main_menu_screen.dart';
import '../features/menu/menu_tile.dart';
import '../features/parent/parent_gate_screen.dart';
import '../features/profiles/profile_picker_screen.dart';
import '../features/profiles/profile_wizard_screen.dart';
import '../features/sandbox/sandbox_screen.dart';
import '../l10n/app_localizations.dart';
import '../state/app_state.dart';
import 'theme/app_theme.dart';

/// Root widget: providers, theme, locale and the start screen.
class ChessForKidsApp extends StatelessWidget {
  const ChessForKidsApp({
    super.key,
    required this.state,
    required this.speaker,
  });

  final AppState state;
  final Speaker speaker;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>.value(value: state),
        ChangeNotifierProvider<Speaker>.value(value: speaker),
      ],
      child: Consumer<AppState>(
        builder: (context, state, _) {
          final settings = state.settings;
          final ui = uiPaletteById(settings.uiPaletteId);
          final board = boardPaletteById(settings.boardPaletteId);
          final code = settings.languageCode;
          return MaterialApp(
            onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
            debugShowCheckedModeBanner: false,
            locale: code == null ? null : Locale(code),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            localeResolutionCallback: (device, supported) =>
                device?.languageCode == 'pl'
                ? const Locale('pl')
                : const Locale('en'),
            theme: buildTheme(ui),
            builder: (context, child) => AppTheme(
              ui: ui,
              board: board,
              child: _SpeakerLanguageSync(child: child!),
            ),
            home: const _Home(),
          );
        },
      ),
    );
  }
}

/// Keeps the speaker's voice in the language the app is displayed in.
class _SpeakerLanguageSync extends StatefulWidget {
  const _SpeakerLanguageSync({required this.child});

  final Widget child;

  @override
  State<_SpeakerLanguageSync> createState() => _SpeakerLanguageSyncState();
}

class _SpeakerLanguageSyncState extends State<_SpeakerLanguageSync> {
  String? _language;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final language = Localizations.localeOf(context).languageCode;
    if (language != _language) {
      _language = language;
      context.read<Speaker>().setLanguage(language);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Picks the first screen from the state: wizard, picker or menu.
class _Home extends StatelessWidget {
  const _Home();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    if (!state.hasProfiles) {
      return const ProfileWizardScreen(canGoBack: false);
    }
    if (state.currentProfile == null) {
      return const ProfilePickerScreen(onSelected: _noop);
    }
    return MainMenuScreen(
      onSection: (section) => _openSection(context, section),
      onParentZone: () => Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const ParentGateScreen())),
    );
  }

  static void _noop() {}

  void _openSection(BuildContext context, MenuSection section) {
    final Widget screen = switch (section) {
      MenuSection.play => const SandboxScreen(),
      MenuSection.learn || MenuSection.miniGames => const ComingSoonScreen(),
    };
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }
}
