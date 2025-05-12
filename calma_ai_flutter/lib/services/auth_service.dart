/**
 * Serviço para autenticação
 * Gerencia login, registro e estado do usuário
 */

import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userEmail;
  String? _userId;

  bool get isAuthenticated => _isAuthenticated;
  String? get userEmail => _userEmail;
  String? get userId => _userId;

  Future<String?> getToken() async {
    if (!_isAuthenticated) return null;
    return 'mock-token-for-testing';
  }

  Future<bool> loginWithEmailAndPassword(String email, String password) async {
    try {
      // Validação básica
      if (email.isEmpty || !email.contains('@') || password.isEmpty) {
        print('Validação falhou: email ou senha inválidos');
        return false;
      }

      // Para fins de teste, aceitar qualquer email/senha válidos
      // Em produção, isso seria substituído por uma chamada real à API

      print('Login bem-sucedido para: $email');

      // Atualizar estado
      _isAuthenticated = true;
      _userEmail = email;
      _userId = 'user-${DateTime.now().millisecondsSinceEpoch}';

      // Notificar ouvintes sobre a mudança de estado
      notifyListeners();

      return true;
    } catch (e) {
      print('Erro no login: $e');
      return false;
    }
  }

  Future<bool> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      // Simulação de registro bem-sucedido
      _isAuthenticated = true;
      _userEmail = email;
      _userId = 'user-${DateTime.now().millisecondsSinceEpoch}';
      notifyListeners();
      return true;
    } catch (e) {
      print('Erro no registro: $e');
      return false;
    }
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _userEmail = null;
    _userId = null;
    notifyListeners();
  }
}
