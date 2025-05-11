// Este arquivo desabilita plugins web problemáticos
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

// Função para desabilitar plugins web específicos
void disableWebPlugins() {
  // Usar uma implementação vazia do registrar para evitar erros
  final Registrar emptyRegistrar = EmptyPluginRegistrar();
  
  // Registrar plugins web com o registrar vazio (efetivamente desabilitando-os)
  webPluginRegistrar.registerMessageHandler();
}

// Implementação vazia do Registrar
class EmptyPluginRegistrar implements Registrar {
  @override
  void registerMessageHandler() {}
  
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}