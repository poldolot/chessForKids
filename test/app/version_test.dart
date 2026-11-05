import 'dart:io';

import 'package:chess_for_kids/app/constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the version shown in the app is the one in pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final line = pubspec
        .split('\n')
        .firstWhere((l) => l.startsWith('version:'));
    final version = line.split(':')[1].trim().split('+').first;
    expect(kAppVersion, version);
  });
}
