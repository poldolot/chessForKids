import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/constants.dart';
import '../../app/theme/app_theme.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../../widgets/teacher_bubble.dart';
import 'avatar_image.dart';

/// Three-step profile creation: teacher theme, avatar, optional name.
/// With [existing], edits that profile instead of creating a new one.
class ProfileWizardScreen extends StatefulWidget {
  const ProfileWizardScreen({super.key, this.existing, this.canGoBack = true});

  final Profile? existing;

  /// Whether a back button is shown on the first step (false on first launch).
  final bool canGoBack;

  @override
  State<ProfileWizardScreen> createState() => _ProfileWizardScreenState();
}

class _ProfileWizardScreenState extends State<ProfileWizardScreen> {
  int _step = 0;
  TeacherTheme? _theme;
  int? _avatar;
  late final TextEditingController _name = TextEditingController(
    text: widget.existing?.name ?? '',
  );

  @override
  void initState() {
    super.initState();
    _theme = widget.existing?.theme;
    _avatar = widget.existing?.avatarIndex;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final state = context.read<AppState>();
    final navigator = Navigator.of(context);
    final name = _name.text.trim();
    final existing = widget.existing;
    final Profile profile;
    if (existing == null) {
      profile = await state.createProfile(
        name: name,
        theme: _theme!,
        avatarIndex: _avatar!,
      );
    } else {
      profile = existing.copyWith(
        name: name,
        theme: _theme!,
        avatarIndex: _avatar!,
      );
      await state.updateProfile(profile);
    }
    if (!navigator.canPop()) {
      return;
    }
    if (existing == null) {
      // A new profile is now selected: go straight to its menu.
      navigator.popUntil((route) => route.isFirst);
    } else {
      navigator.pop(profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = AppTheme.of(context).ui;
    final bubbleTheme = _theme ?? TeacherTheme.animals;
    final (title, key) = switch (_step) {
      0 => (l10n.chooseTeachers, 'wizard.chooseTeachers'),
      1 => (l10n.chooseAvatar, 'wizard.chooseAvatar'),
      _ => (l10n.yourName, 'wizard.yourName'),
    };
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  if (_step > 0 || widget.canGoBack)
                    IconButton(
                      key: const Key('wizard-back'),
                      tooltip: l10n.back,
                      iconSize: 32,
                      onPressed: () {
                        if (_step == 0) {
                          Navigator.of(context).maybePop();
                        } else {
                          setState(() => _step--);
                        }
                      },
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                  Expanded(
                    child: TeacherBubble(
                      theme: bubbleTheme,
                      avatarIndex: _avatar ?? 1,
                      text: title,
                      speechKey: key,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: switch (_step) {
                  0 => _ThemeGrid(
                    selected: _theme,
                    onSelected: (t) => setState(() {
                      _theme = t;
                      _step = 1;
                    }),
                  ),
                  1 => _AvatarGrid(
                    theme: _theme!,
                    selected: _avatar,
                    onSelected: (i) => setState(() {
                      _avatar = i;
                      _step = 2;
                    }),
                  ),
                  _ => _NameStep(controller: _name, hint: l10n.nameHint),
                },
              ),
              if (_step == 2)
                FilledButton.icon(
                  key: const Key('wizard-done'),
                  onPressed: _finish,
                  icon: const Icon(Icons.check_rounded, size: 28),
                  label: Text(l10n.done),
                  style: FilledButton.styleFrom(
                    backgroundColor: palette.games,
                    minimumSize: const Size.fromHeight(64),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Two rows of two tiles that always fit the available height.
class _FourTiles extends StatelessWidget {
  const _FourTiles({required this.tiles});

  final List<Widget> tiles;

  Widget _row(Widget left, Widget right) => Expanded(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: left),
        const SizedBox(width: 16),
        Expanded(child: right),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    assert(tiles.length == 4);
    return Column(
      children: [
        _row(tiles[0], tiles[1]),
        const SizedBox(height: 16),
        _row(tiles[2], tiles[3]),
      ],
    );
  }
}

class _ThemeGrid extends StatelessWidget {
  const _ThemeGrid({required this.selected, required this.onSelected});

  final TeacherTheme? selected;
  final ValueChanged<TeacherTheme> onSelected;

  @override
  Widget build(BuildContext context) {
    return _FourTiles(
      tiles: [
        for (final theme in TeacherTheme.values)
          _ChoiceTile(
            key: Key('theme-${theme.name}'),
            selected: theme == selected,
            onTap: () => onSelected(theme),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AvatarImage(theme, 1, size: 84),
                    const SizedBox(width: 4),
                    AvatarImage(theme, 2, size: 84),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _AvatarGrid extends StatelessWidget {
  const _AvatarGrid({
    required this.theme,
    required this.selected,
    required this.onSelected,
  });

  final TeacherTheme theme;
  final int? selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return _FourTiles(
      tiles: [
        for (var i = 1; i <= 4; i++)
          _ChoiceTile(
            key: Key('avatar-$i'),
            selected: i == selected,
            onTap: () => onSelected(i),
            child: Center(child: AvatarImage(theme, i, size: 150)),
          ),
      ],
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    super.key,
    required this.selected,
    required this.onTap,
    required this.child,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = AppTheme.of(context).ui;
    return Material(
      color: palette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: selected ? palette.accentDeep : Colors.transparent,
          width: 4,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: kMinTouchTarget),
          child: child,
        ),
      ),
    );
  }
}

class _NameStep extends StatelessWidget {
  const _NameStep({required this.controller, required this.hint});

  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          key: const Key('name-field'),
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          style: const TextStyle(fontSize: 26),
          decoration: InputDecoration(
            helperText: hint,
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
          ),
        ),
      ],
    );
  }
}
