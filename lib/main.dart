import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'app/app.dart';
import 'core/tts_speaker.dart';
import 'data/app_repository.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final repository = AppRepository(await getApplicationDocumentsDirectory());
  final state = await AppState.load(repository);
  final speaker = TtsSpeaker()
    ..enabled = state.settings.voiceEnabled
    ..rate = state.settings.speechRate;
  runApp(ChessForKidsApp(state: state, speaker: speaker));
}
