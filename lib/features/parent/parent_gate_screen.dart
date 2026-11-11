import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../app/constants.dart';
import '../../app/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import 'parent_zone_screen.dart';

/// A small sum a child cannot solve yet. Three wrong answers close the gate.
class ParentGateScreen extends StatefulWidget {
  const ParentGateScreen({super.key, this.random});

  final Random? random;

  @override
  State<ParentGateScreen> createState() => _ParentGateScreenState();
}

class _ParentGateScreenState extends State<ParentGateScreen> {
  late final Random _random = widget.random ?? Random();
  late int _a;
  late int _b;
  String _answer = '';
  int _wrong = 0;
  bool _showError = false;
  bool _cursorOn = true;
  Timer? _blink;

  static const Duration _blinkPeriod = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _newTask();
    _blink = Timer.periodic(_blinkPeriod, (_) {
      setState(() => _cursorOn = !_cursorOn);
    });
  }

  @override
  void dispose() {
    _blink?.cancel();
    super.dispose();
  }

  void _newTask() {
    _a = 2 + _random.nextInt(8);
    _b = 2 + _random.nextInt(8);
    _answer = '';
  }

  void _press(String digit) {
    if (_answer.length >= 2) {
      return;
    }
    setState(() {
      _answer += digit;
      _showError = false;
    });
  }

  void _backspace() {
    if (_answer.isEmpty) {
      return;
    }
    setState(() => _answer = _answer.substring(0, _answer.length - 1));
  }

  void _submit() {
    if (int.tryParse(_answer) == _a + _b) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const ParentZoneScreen()),
      );
      return;
    }
    _wrong++;
    if (_wrong >= 3) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _showError = true;
      _newTask();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = AppTheme.of(context).ui;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.gateTitle),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                '$_a + $_b = ?',
                style: TextStyle(
                  color: palette.text,
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 120,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _showError ? palette.play : palette.muted,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _answer,
                      key: const Key('gate-answer'),
                      style: TextStyle(
                        color: palette.text,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    AnimatedOpacity(
                      key: const Key('gate-cursor'),
                      opacity: _cursorOn ? 1 : 0,
                      duration: const Duration(milliseconds: 120),
                      child: Container(
                        width: 2,
                        height: 34,
                        margin: const EdgeInsets.only(left: 2),
                        color: palette.text,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 24,
                child: _showError
                    ? Text(
                        l10n.gateWrong,
                        style: TextStyle(color: palette.muted),
                      )
                    : null,
              ),
              const Spacer(),
              _Keypad(onDigit: _press, onBackspace: _backspace, onOk: _submit),
            ],
          ),
        ),
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({
    required this.onDigit,
    required this.onBackspace,
    required this.onOk,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback onOk;

  @override
  Widget build(BuildContext context) {
    final palette = AppTheme.of(context).ui;
    Widget key(String id, Widget child, VoidCallback onTap, {Color? color}) {
      return Padding(
        padding: const EdgeInsets.all(6),
        child: Material(
          key: Key('key-$id'),
          color: color ?? palette.surface,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: SizedBox(
              width: 76,
              height: kMinTouchTarget + 4,
              child: Center(child: child),
            ),
          ),
        ),
      );
    }

    final digitStyle = TextStyle(
      color: palette.text,
      fontSize: 26,
      fontWeight: FontWeight.w700,
    );
    final rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in rows)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final d in row)
                key(d, Text(d, style: digitStyle), () => onDigit(d)),
            ],
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            key(
              'back',
              Icon(Icons.backspace_outlined, color: palette.text),
              onBackspace,
            ),
            key('0', Text('0', style: digitStyle), () => onDigit('0')),
            key(
              'ok',
              Icon(Icons.check_rounded, color: palette.text, size: 30),
              onOk,
              color: palette.accent,
            ),
          ],
        ),
      ],
    );
  }
}
