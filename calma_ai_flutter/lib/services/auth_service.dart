/**
 * Serviço para autenticação com Firebase
 * Gerencia login, registro e estado do usuário
 */

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  // Construtor
  AuthService() {
    // Ouvir mudanças no estado de autenticação
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
    
    // Carregar usuário do cache
    _loadUserFromCache();
  }

  // Carregar usuário do cache
  Future<void> _loadUserFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString('user_email');
      
      if (userEmail != null && _user == null) {
        // Usuário estava logado anteriormente, mas não está autenticado agora
        // Isso pode acontecer se o token expirou
        _error = 'Sessão expirada. Por favor, faça login novamente.';
      }
    } catch (e) {
      print('Erro ao carregar usuário do cache: $e');
    }
  }

  // Salvar usuário no cache
  Future<void> _saveUserToCache(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', user.email ?? '');
      await prefs.setString('user_id', user.uid);
    } catch (e) {
      print('Erro ao salvar usuário no cache: $e');
    }
  }

  // Limpar usuário do cache
  Future<void> _clearUserFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_email');
      await prefs.remove('user_id');
    } catch (e) {
      print('Erro ao limpar usuário do cache: $e');
    }
  }

  // Login com e-mail e senha
  Future<bool> loginWithEmailAndPassword(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _user = result.user;
      
      if (_user != null) {
        await _saveUserToCache(_user!);
      }
      
      _isLoading = false;
      notifyListeners();
      return _user != null;
    } catch (e) {
      _isLoading = false;
      _error = _handleAuthError(e);
      notifyListeners();
      return false;
    }
  }

  // Registro com e-mail e senha
  Future<bool> registerWithEmailAndPassword(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _user = result.user;
      
      if (_user != null) {
        await _saveUserToCache(_user!);
      }
      
      _isLoading = false;
      notifyListeners();
      return _user != null;
    } catch (e) {
      _isLoading = false;
      _error = _handleAuthError(e);
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
      _user = null;
      await _clearUserFromCache();
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao fazer logout: ${e.toString()}';
      notifyListeners();
    }
  }

  // Obter token de autenticação
  Future<String?> getToken() async {
    try {
      if (_user != null) {
        return await _user!.getIdToken();
      }
      return null;
    } catch (e) {
      _error = 'Erro ao obter token: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  // Tratar erros de autenticação
  String _handleAuthError(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'Usuário não encontrado.';
        case 'wrong-password':
          return 'Senha incorreta.';
        case 'email-already-in-use':
          return 'Este e-mail já está em uso.';
        case 'weak-password':
          return 'A senha é muito fraca.';
        case 'invalid-email':
          return 'E-mail inválido.';
        default:
          return 'Erro de autenticação: ${e.message}';
      }
    }
    return 'Erro desconhecido: ${e.toString()}';
  }
}
