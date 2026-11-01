import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../../widgets/teacher_bubble.dart';

/// Placeholder for sections that later plans fill in.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profile = context.watch<AppState>().currentProfile;
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: TeacherBubble(
            theme: profile?.theme ?? TeacherTheme.animals,
            avatarIndex: 3,
            text: l10n.comingSoon,
            speechKey: 'menu.comingSoon',
            avatarSize: 96,
          ),
        ),
      ),
    );
  }
}
