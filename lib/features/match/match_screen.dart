import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_theme.dart';
import '../../core/speaker.dart';
import '../../data/models.dart';
import '../../engine/engine.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../../widgets/game_layout.dart';
import '../../widgets/teacher_bubble.dart';
import '../board/board_highlights.dart';
import '../board/interactive_board.dart';
import 'match_result_view.dart';
import 'match_session.dart';
import 'match_strings.dart';
import 'widgets/resign_dialog.dart';
import 'widgets/thinking_dots.dart';

/// A match against the computer.
class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key, this.session, this.thinkingDelay, this.random});

  /// The match to show; `null` starts a new one from the settings.
  final MatchSession? session;

  /// How long the computer "thinks" before each move; `null` draws
  /// 500–1500 ms per move.
  final Duration? thinkingDelay;
  final Random? random;

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  static const Duration _hintDuration = Duration(seconds: 2);
  static const int _minThinkMs = 500;
  static const int _maxThinkMs = 1500;

  late final Random _random = widget.random ?? Random();
  late MatchSession _session;
  late String _lineKey;
  bool _lineInterrupts = true;
  bool _lineSpeaks = true;

  /// The last line the bubble was asked to speak; "your move" is repeated
  /// only after something else was said.
  late String _lastSpokenKey;
  bool _thinking = false;
  Timer? _thinkTimer;
  Move? _hint;
  Timer? _hintTimer;

  @override
  void initState() {
    super.initState();
    _session = widget.session ?? _restoredSession() ?? _newSession();
    _session.addListener(_onSession);
    _lineKey = _openingKey();
    _lastSpokenKey = _lineKey;
    WidgetsBinding.instance.addPostFrameCallback((_) => _scheduleComputer());
  }

  /// The match saved in the profile, or `null` when there is none or it
  /// cannot be read (a broken save is cleared).
  MatchSession? _restoredSession() {
    final state = context.read<AppState>();
    final json = state.currentProfile?.savedGameJson;
    if (json == null) {
      return null;
    }
    try {
      final decoded = jsonDecode(json);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Saved match is not an object');
      }
      final session = MatchSession.fromJson(decoded, random: _random);
      return session.result.isOver ? null : session;
    } on FormatException {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          state.saveMatch(null);
        }
      });
      return null;
    }
  }

  @override
  void dispose() {
    _thinkTimer?.cancel();
    _hintTimer?.cancel();
    _session.removeListener(_onSession);
    _session.dispose();
    super.dispose();
  }

  MatchSession _newSession() {
    final settings = context.read<AppState>().settings;
    return MatchSession(
      childColor: MatchSession.pickChildColor(settings.childColor, _random),
      random: _random,
    );
  }

  String _openingKey() {
    if (_session.lastMove == null) {
      return _session.childColor == PieceColor.white
          ? 'match.intro'
          : 'match.introBlack';
    }
    return _session.computerToMove ? 'match.thinking' : 'match.yourMove';
  }

  void _onSession() {
    if (mounted) {
      setState(() {});
    }
  }

  /// Changes the bubble line; spoken unless [speak] is false. The bubble
  /// speaks on a text change, so a silent "thinking" line in between lets
  /// two checks in a row both be heard.
  void _setLine(String key, {bool interrupt = false, bool speak = true}) {
    setState(() {
      _lineKey = key;
      _lineInterrupts = interrupt;
      _lineSpeaks = speak;
    });
    if (speak) {
      _lastSpokenKey = key;
    }
  }

  void _save() {
    final state = context.read<AppState>();
    if (state.currentProfile == null) {
      return;
    }
    state.saveMatch(jsonEncode(_session.toJson()));
  }

  Duration get _thinkingDelay =>
      widget.thinkingDelay ??
      Duration(
        milliseconds:
            _minThinkMs + _random.nextInt(_maxThinkMs - _minThinkMs + 1),
      );

  void _scheduleComputer() {
    if (!mounted || _thinking || !_session.computerToMove) {
      return;
    }
    setState(() => _thinking = true);
    _thinkTimer?.cancel();
    _thinkTimer = Timer(_thinkingDelay, _computerMoves);
  }

  void _computerMoves() {
    if (!mounted) {
      return;
    }
    _thinking = false;
    final move = _session.playComputer();
    if (move == null) {
      setState(() {});
      return;
    }
    _save();
    if (_session.result.isOver) {
      return;
    }
    if (_session.isCheck) {
      _setLine('match.check', interrupt: true);
    } else {
      _setLine('match.yourMove', speak: _lastSpokenKey != 'match.yourMove');
    }
  }

  void _onChildMove(Move move) {
    _clearHint();
    _session.playChild(move);
    _save();
    if (_session.result.isOver) {
      return;
    }
    if (_session.isCheck) {
      _setLine('match.checkByYou');
    } else {
      _setLine('match.thinking', speak: false);
    }
    _scheduleComputer();
  }

  void _undo() {
    _clearHint();
    if (_thinking) {
      _thinkTimer?.cancel();
      _thinking = false;
    }
    _session.undo();
    _save();
    _setLine('match.yourMove', speak: false);
  }

  void _showHint() {
    final hint = _session.hint();
    if (hint == null) {
      return;
    }
    setState(() => _hint = hint);
    final l10n = AppLocalizations.of(context);
    context.read<Speaker>().say(
      matchLine(l10n, 'match.hint'),
      key: 'match.hint',
      interrupt: false,
    );
    _lastSpokenKey = 'match.hint';
    _hintTimer?.cancel();
    _hintTimer = Timer(_hintDuration, _clearHint);
  }

  void _clearHint() {
    _hintTimer?.cancel();
    if (_hint != null && mounted) {
      setState(() => _hint = null);
    }
  }

  Future<void> _resign() async {
    if (await showResignDialog(context) && mounted) {
      _clearHint();
      _thinkTimer?.cancel();
      _thinking = false;
      _session.resign();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = AppTheme.of(context).ui;
    final profile = context.watch<AppState>().currentProfile;
    final theme = profile?.theme ?? TeacherTheme.animals;
    final session = _session;
    return Scaffold(
      appBar: AppBar(
        title: Text(matchLine(l10n, 'match.title')),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: session.result.isOver
              ? _buildResult(session)
              : _buildPlay(l10n, palette, theme, session),
        ),
      ),
    );
  }

  Widget _buildPlay(
    AppLocalizations l10n,
    UiPalette palette,
    TeacherTheme theme,
    MatchSession session,
  ) {
    final hint = _hint;
    final childTurn = session.childToMove && !_thinking;
    return GameLayout(
      bubble: TeacherBubble(
        theme: theme,
        avatarIndex: 4,
        text: matchLine(l10n, _lineKey),
        speechKey: _lineKey,
        interrupt: _lineInterrupts,
        speakOnShow: _lineSpeaks,
      ),
      slot: _thinking
          ? const ThinkingDots(key: Key('thinking'))
          : const SizedBox.shrink(),
      board: InteractiveBoard(
        position: session.position,
        onMove: _onChildMove,
        orientation: session.childColor,
        movableColor: session.childColor,
        moveFilter: session.allows,
        lastMove: session.lastMove,
        enabled: childTurn,
        extraHighlights: BoardHighlights(
          selected: hint?.from,
          moveTargets: hint == null ? const {} : {hint.to},
        ),
      ),
      controls: Row(
        children: [
          SizedBox(
            width: GameLayout.controlsHeight,
            height: GameLayout.controlsHeight,
            child: OutlinedButton(
              key: const Key('match-undo'),
              onPressed: session.canUndo ? _undo : null,
              style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
              child: Tooltip(
                message: matchLine(l10n, 'match.undo'),
                child: const Icon(Icons.undo_rounded, size: 30),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              key: const Key('match-hint'),
              onPressed: childTurn ? _showHint : null,
              icon: const Icon(Icons.lightbulb_rounded),
              label: Text(matchLine(l10n, 'match.hint')),
              style: FilledButton.styleFrom(
                backgroundColor: palette.accent,
                minimumSize: const Size.fromHeight(GameLayout.controlsHeight),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: GameLayout.controlsHeight,
            height: GameLayout.controlsHeight,
            child: OutlinedButton(
              key: const Key('match-resign'),
              onPressed: childTurn ? _resign : null,
              style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
              child: Tooltip(
                message: matchLine(l10n, 'match.resign'),
                child: const Icon(Icons.flag_rounded, size: 30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _again() {
    _clearHint();
    _thinkTimer?.cancel();
    _thinking = false;
    _session.removeListener(_onSession);
    _session.dispose();
    _session = _newSession();
    _session.addListener(_onSession);
    setState(() {
      _lineKey = _openingKey();
      _lineInterrupts = true;
      _lineSpeaks = true;
    });
    _lastSpokenKey = _lineKey;
    WidgetsBinding.instance.addPostFrameCallback((_) => _scheduleComputer());
  }

  Widget _buildResult(MatchSession session) => MatchResultView(
    key: ValueKey(session),
    session: session,
    onAgain: _again,
    onBack: () => Navigator.of(context).pop(),
  );
}
