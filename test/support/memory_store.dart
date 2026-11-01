import 'package:chess_for_kids/data/app_store.dart';
import 'package:chess_for_kids/data/models.dart';

/// In-memory [AppStore] for widget tests (file IO does not complete under
/// the widget tester's fake async).
final class MemoryStore implements AppStore {
  MemoryStore([this.data = const AppData()]);

  AppData data;
  int saves = 0;

  @override
  Future<AppData> load() async => data;

  @override
  Future<void> save(AppData data) async {
    this.data = data;
    saves++;
  }
}
