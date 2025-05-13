// Registrante de plugins web personalizado
// Substitui o registrante automático gerado pelo Flutter

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:shared_preferences_web/shared_preferences_web.dart';
import 'package:audioplayers_web/audioplayers_web.dart';

// Registrar plugins web manualmente, excluindo firebase_auth_web
void registerPlugins(Registrar registrar) {
  FirebaseCoreWeb.registerWith(registrar);
  SharedPreferencesPlugin.registerWith(registrar);
  AudioplayersPlugin.registerWith(registrar);
  registrar.registerMessageHandler();
}
