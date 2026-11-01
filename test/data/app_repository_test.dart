import 'dart:io';

import 'package:chess_for_kids/data/app_repository.dart';
import 'package:chess_for_kids/data/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory dir;
  late AppRepository repo;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('chess_repo_');
    repo = AppRepository(dir);
  });

  tearDown(() => dir.delete(recursive: true));

  File stateFile() => File('${dir.path}/${AppRepository.fileName}');
  File backupFile() => File('${dir.path}/${AppRepository.backupName}');

  test('load returns defaults when no file exists', () async {
    expect(await repo.load(), const AppData());
  });

  test('save then load round-trips', () async {
    const data = AppData(
      profiles: [
        Profile(id: 'a', name: 'Ala', theme: TeacherTheme.ufo, avatarIndex: 3),
      ],
      lastProfileId: 'a',
    );
    await repo.save(data);
    expect(await repo.load(), data);
    expect(stateFile().existsSync(), isTrue);
  });

  test('corrupt file is backed up and defaults are returned', () async {
    stateFile().writeAsStringSync('{not json');
    expect(await repo.load(), const AppData());
    expect(backupFile().readAsStringSync(), '{not json');
    expect(stateFile().existsSync(), isFalse);
  });

  test('file from a newer version is backed up too', () async {
    stateFile().writeAsStringSync('{"version": 99}');
    expect(await repo.load(), const AppData());
    expect(backupFile().existsSync(), isTrue);
  });

  test('save leaves no temp file behind', () async {
    await repo.save(const AppData());
    expect(dir.listSync().map((e) => e.uri.pathSegments.last), [
      AppRepository.fileName,
    ]);
  });
}
