import 'package:flutter/material.dart';

import '../../../app/constants.dart';
import '../../../app/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../match_strings.dart';

/// Asks the child whether to give up, with a flag and two big picture
/// buttons: a cross (keep playing) and a check mark (resign). Returns true
/// when the child confirmed.
Future<bool> showResignDialog(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final palette = AppTheme.of(context).ui;
  final answer = await showDialog<bool>(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: palette.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.flag_rounded, size: 64, color: palette.accentDeep),
            const SizedBox(height: 12),
            Text(
              matchLine(l10n, 'match.resignQuestion'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: palette.text,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    key: const Key('resign-no'),
                    onPressed: () => Navigator.of(context).pop(false),
                    icon: const Icon(Icons.close_rounded, size: 28),
                    label: Text(matchLine(l10n, 'match.no')),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(kMinTouchTarget),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    key: const Key('resign-yes'),
                    onPressed: () => Navigator.of(context).pop(true),
                    icon: const Icon(Icons.check_rounded, size: 28),
                    label: Text(matchLine(l10n, 'match.yes')),
                    style: FilledButton.styleFrom(
                      backgroundColor: palette.accent,
                      minimumSize: const Size.fromHeight(kMinTouchTarget),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  return answer ?? false;
}
