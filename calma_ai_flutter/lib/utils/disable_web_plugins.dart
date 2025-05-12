import 'package:flutter/foundation.dart';

/// Desabilita plugins problemáticos na web
void disableWebPlugins() {
  if (kIsWeb) {
    // Aqui você pode adicionar código para desabilitar plugins específicos
    // que causam problemas na web
    print('Plugins web problemáticos desabilitados');
  }
}
