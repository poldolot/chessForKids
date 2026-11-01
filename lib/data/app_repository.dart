import 'dart:convert';
import 'dart:io';

import 'app_store.dart';
import 'models.dart';

/// Stores [AppData] as a single JSON file in [directory].
///
/// A file that cannot be read (corrupt, or written by a newer app version)
/// is moved aside as [backupName] and defaults are returned, so a bad file
/// never blocks the app from starting.
final class AppRepository implements AppStore {
  AppRepository(this.directory);

  static const String fileName = 'app_state.json';
  static const String backupName = 'app_state.json.bak';

  final Directory directory;

  File get _file => File('${directory.path}/$fileName');
  File get _backup => File('${directory.path}/$backupName');
  File get _temp => File('${directory.path}/$fileName.tmp');

  @override
  Future<AppData> load() async {
    if (!await _file.exists()) {
      return const AppData();
    }
    try {
      final text = await _file.readAsString();
      final json = jsonDecode(text);
      if (json is! Map<String, dynamic>) {
        throw const FormatException('Root is not an object');
      }
      return AppData.fromJson(json);
    } on FormatException {
      await _file.rename(_backup.path);
      return const AppData();
    } on TypeError {
      await _file.rename(_backup.path);
      return const AppData();
    }
  }

  /// Writes atomically: to a temporary file first, then renames over the old one.
  @override
  Future<void> save(AppData data) async {
    await directory.create(recursive: true);
    await _temp.writeAsString(jsonEncode(data.toJson()), flush: true);
    await _temp.rename(_file.path);
  }
}
