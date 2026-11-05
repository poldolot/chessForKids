import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../ai/ai.dart';
import '../../app/constants.dart';
import '../../app/theme/app_theme.dart';
import '../../core/speaker.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../profiles/avatar_image.dart';
import '../profiles/profile_wizard_screen.dart';

/// Version shown in the About section; kept in sync with pubspec.yaml by hand.

/// Settings for parents: players, language, voice, colors, match color,
/// mini-game unlocking and the about box.
class ParentZoneScreen extends StatelessWidget {
  const ParentZoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<AppState>();
    final speaker = context.watch<Speaker>();
    final settings = state.settings;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.parentZone),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          _Section(
            title: l10n.profiles,
            children: [
              for (final profile in state.profiles)
                _ProfileRow(
                  profile: profile,
                  isCurrent: profile.id == state.currentProfile?.id,
                ),
            ],
          ),
          _Section(
            title: l10n.language,
            children: [
              SegmentedButton<String?>(
                segments: [
                  ButtonSegment(
                    value: null,
                    label: Text(
                      l10n.systemLanguage,
                      key: const Key('lang-system'),
                    ),
                  ),
                  ButtonSegment(
                    value: 'pl',
                    label: Text(l10n.polish, key: const Key('lang-pl')),
                  ),
                  ButtonSegment(
                    value: 'en',
                    label: Text(l10n.english, key: const Key('lang-en')),
                  ),
                ],
                selected: {settings.languageCode},
                onSelectionChanged: (s) => state.updateSettings(
                  settings.copyWith(
                    languageCode: s.first,
                    clearLanguage: s.first == null,
                  ),
                ),
              ),
            ],
          ),
          _Section(
            title: l10n.voice,
            children: [
              SwitchListTile(
                key: const Key('voice-switch'),
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.voiceEnabled),
                value: settings.voiceEnabled,
                onChanged: (v) {
                  speaker.enabled = v;
                  state.updateSettings(settings.copyWith(voiceEnabled: v));
                },
              ),
              Text(l10n.speechRate),
              const SizedBox(height: 6),
              SegmentedButton<SpeechRate>(
                segments: [
                  ButtonSegment(
                    value: SpeechRate.slow,
                    label: Text(l10n.slow, key: const Key('rate-slow')),
                  ),
                  ButtonSegment(
                    value: SpeechRate.normal,
                    label: Text(l10n.normal, key: const Key('rate-normal')),
                  ),
                  ButtonSegment(
                    value: SpeechRate.fast,
                    label: Text(l10n.fast, key: const Key('rate-fast')),
                  ),
                ],
                selected: {settings.speechRate},
                onSelectionChanged: (s) {
                  speaker.rate = s.first;
                  state.updateSettings(settings.copyWith(speechRate: s.first));
                },
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                key: const Key('test-voice'),
                onPressed: () =>
                    speaker.say(l10n.greeting, key: 'parent.testVoice'),
                icon: const Icon(Icons.volume_up_rounded),
                label: Text(l10n.testVoice),
              ),
              if (!speaker.available)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    l10n.voiceUnavailable,
                    key: const Key('voice-unavailable'),
                  ),
                ),
            ],
          ),
          _Section(
            title: l10n.colors,
            children: [
              Text(l10n.uiColors),
              const SizedBox(height: 6),
              Wrap(
                spacing: 12,
                children: [
                  for (final p in uiPalettes)
                    _Swatch(
                      key: Key('ui-palette-${p.id}'),
                      colors: [p.background, p.accent, p.games],
                      selected: p.id == settings.uiPaletteId,
                      onTap: () => state.updateSettings(
                        settings.copyWith(uiPaletteId: p.id),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(l10n.boardColors),
              const SizedBox(height: 6),
              Wrap(
                spacing: 12,
                children: [
                  for (final p in boardPalettes)
                    _Swatch(
                      key: Key('board-palette-${p.id}'),
                      colors: [p.light, p.dark],
                      selected: p.id == settings.boardPaletteId,
                      onTap: () => state.updateSettings(
                        settings.copyWith(boardPaletteId: p.id),
                      ),
                    ),
                ],
              ),
            ],
          ),
          _Section(
            title: l10n.childPlays,
            children: [
              SegmentedButton<ChildColor>(
                segments: [
                  ButtonSegment(
                    value: ChildColor.white,
                    label: Text(
                      l10n.alwaysWhite,
                      key: const Key('child-white'),
                    ),
                  ),
                  ButtonSegment(
                    value: ChildColor.random,
                    label: Text(
                      l10n.randomColor,
                      key: const Key('child-random'),
                    ),
                  ),
                ],
                selected: {settings.childColor},
                onSelectionChanged: (s) => state.updateSettings(
                  settings.copyWith(childColor: s.first),
                ),
              ),
            ],
          ),
          if (state.currentProfile case final profile?)
            _Section(
              title: l10n.computerLevel,
              children: [
                SegmentedButton<MatchLevel>(
                  segments: [
                    for (final level in MatchLevel.values)
                      ButtonSegment(
                        value: level,
                        label: Text(switch (level) {
                          MatchLevel.veryEasy => l10n.levelVeryEasy,
                          MatchLevel.easy => l10n.levelEasy,
                          MatchLevel.normal => l10n.levelNormal,
                        }, key: Key('level-${level.name}')),
                      ),
                  ],
                  selected: {profile.matchLevel},
                  onSelectionChanged: (s) => state.updateProfile(
                    profile.copyWith(matchLevel: s.first),
                  ),
                ),
              ],
            ),
          if (state.currentProfile case final profile?)
            _Section(
              title: l10n.miniGamesSettings,
              children: [
                SwitchListTile(
                  key: const Key('unlock-minigames'),
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.unlockAllMiniGames),
                  value: profile.unlockAllMiniGames,
                  onChanged: (v) => state.updateProfile(
                    profile.copyWith(unlockAllMiniGames: v),
                  ),
                ),
              ],
            ),
          _Section(
            title: l10n.about,
            children: [
              Text(l10n.version(kAppVersion)),
              const SizedBox(height: 6),
              Text(l10n.offlineNotice, key: const Key('offline-notice')),
              const SizedBox(height: 6),
              TextButton(
                onPressed: () => showLicensePage(
                  context: context,
                  applicationName: l10n.appTitle,
                  applicationVersion: kAppVersion,
                ),
                child: Text(l10n.licenses),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final palette = AppTheme.of(context).ui;
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: palette.muted,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.profile, required this.isCurrent});

  final Profile profile;
  final bool isCurrent;

  Future<bool> _confirm(BuildContext context, String question) async {
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(question),
        actions: [
          TextButton(
            key: const Key('cancel'),
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            key: const Key('confirm'),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = AppTheme.of(context).ui;
    final state = context.read<AppState>();
    final name = profile.name.isEmpty ? l10n.unnamedPlayer : profile.name;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            AvatarImage(profile.theme, profile.avatarIndex, size: 48),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  color: palette.text,
                  fontSize: 18,
                  fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ),
            IconButton(
              key: Key('profile-edit-${profile.id}'),
              tooltip: l10n.editProfile,
              icon: const Icon(Icons.edit_rounded),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<Profile>(
                  builder: (_) => ProfileWizardScreen(existing: profile),
                ),
              ),
            ),
            IconButton(
              key: Key('profile-reset-${profile.id}'),
              tooltip: l10n.resetProgress,
              icon: const Icon(Icons.restart_alt_rounded),
              onPressed: () async {
                if (await _confirm(context, l10n.resetProgressQuestion(name))) {
                  await state.resetProgress(profile.id);
                }
              },
            ),
            IconButton(
              key: Key('profile-delete-${profile.id}'),
              tooltip: l10n.deleteProfile,
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () async {
                final navigator = Navigator.of(context);
                if (await _confirm(context, l10n.deleteProfileQuestion(name))) {
                  await state.deleteProfile(profile.id);
                  if (isCurrent) {
                    navigator.popUntil((route) => route.isFirst);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    super.key,
    required this.colors,
    required this.selected,
    required this.onTap,
  });

  final List<Color> colors;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppTheme.of(context).ui;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: 64,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? palette.accentDeep
                : palette.muted.withValues(alpha: 0.3),
            width: selected ? 4 : 2,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final c in colors) Expanded(child: ColoredBox(color: c)),
          ],
        ),
      ),
    );
  }
}
