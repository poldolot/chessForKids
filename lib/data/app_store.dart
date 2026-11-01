import 'models.dart';

/// Where [AppData] is persisted. The app uses a JSON file; tests use memory.
abstract interface class AppStore {
  Future<AppData> load();
  Future<void> save(AppData data);
}
