import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_theme.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../../widgets/teacher_bubble.dart';
import 'avatar_image.dart';
import 'profile_wizard_screen.dart';

/// "Who is playing?": big avatars, one per profile, plus an add button.
class ProfilePickerScreen extends StatelessWidget {
  const ProfilePickerScreen({super.key, this.onSelected});

  /// Called after a profile was selected (defaults to popping the route).
  final VoidCallback? onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = AppTheme.of(context).ui;
    final state = context.watch<AppState>();
    final first = state.profiles.isEmpty ? null : state.profiles.first;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TeacherBubble(
                theme: first?.theme ?? TeacherTheme.animals,
                avatarIndex: 1,
                text: l10n.whoIsPlaying,
                speechKey: 'profiles.whoIsPlaying',
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    for (final profile in state.profiles)
                      _ProfileTile(
                        profile: profile,
                        onTap: () async {
                          await state.selectProfile(profile.id);
                          if (!context.mounted) {
                            return;
                          }
                          if (onSelected != null) {
                            onSelected!();
                          } else {
                            Navigator.of(context).maybePop();
                          }
                        },
                      ),
                    Material(
                      key: const Key('add-profile'),
                      color: palette.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                        side: BorderSide(color: palette.muted, width: 2),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(22),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<Profile>(
                            builder: (_) => const ProfileWizardScreen(),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_rounded,
                              size: 64,
                              color: palette.muted,
                            ),
                            Text(
                              l10n.addProfile,
                              style: TextStyle(color: palette.muted),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({required this.profile, required this.onTap});

  final Profile profile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppTheme.of(context).ui;
    return Material(
      key: Key('profile-${profile.id}'),
      color: palette.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AvatarImage(profile.theme, profile.avatarIndex, size: 112),
            if (profile.name.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  profile.name,
                  style: TextStyle(
                    color: palette.text,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
