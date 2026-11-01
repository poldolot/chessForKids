import 'package:chess_for_kids/features/learn/lesson_model.dart';
import 'package:chess_for_kids/features/learn/lesson_strings.dart';
import 'package:chess_for_kids/features/learn/lessons/catalog.dart';
import 'package:chess_for_kids/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppLocalizations en;
  late AppLocalizations pl;

  setUpAll(() async {
    en = await AppLocalizations.delegate.load(const Locale('en'));
    pl = await AppLocalizations.delegate.load(const Locale('pl'));
  });

  test('lines resolve in both languages', () {
    expect(
      learnLine(en, 'learn.rook.practice'),
      'Collect the stars in five moves!',
    );
    expect(
      learnLine(pl, 'learn.king.hint'),
      'Tam król byłby w niebezpieczeństwie.',
    );
    expect(learnLine(pl, 'learn.title'), 'Nauka');
    expect(learnLine(en, 'learn.common.tryAgain'), 'Try again!');
  });

  test('unknown keys throw', () {
    expect(() => learnLine(en, 'learn.nope'), throwsArgumentError);
  });

  test('every lesson key used by the catalog exists', () {
    for (final lesson in lessons) {
      expect(
        learnLine(en, lesson.titleKey),
        isNotEmpty,
        reason: lesson.titleKey,
      );
      for (final step in lesson.steps) {
        expect(learnLine(en, step.lineKey), isNotEmpty, reason: step.lineKey);
        expect(learnLine(pl, step.lineKey), isNotEmpty, reason: step.lineKey);
        if (step is BoardTaskStep && step.hintKey != null) {
          expect(
            learnLine(en, step.hintKey!),
            isNotEmpty,
            reason: step.hintKey,
          );
        }
        if (step is DemoStep) {
          for (final (_, key) in step.moves) {
            if (key != null) {
              expect(learnLine(en, key), isNotEmpty, reason: key);
            }
          }
        }
      }
    }
  });
}
