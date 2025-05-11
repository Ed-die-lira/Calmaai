// Este arquivo fornece uma implementação temporária para PromiseJsImpl
// para resolver problemas de compilação com firebase_auth_web

import 'package:js/js.dart';

// Definição da classe PromiseJsImpl que está faltando
@JS('Promise')
class PromiseJsImpl<T> {
  external PromiseJsImpl(Function executor);
  external PromiseJsImpl then(Function onFulfilled, [Function? onRejected]);

  // Renomeando 'catch' para 'onCatch' para evitar conflito com a palavra-chave
  @JS('catch')
  external PromiseJsImpl onCatch(Function onRejected);
}
