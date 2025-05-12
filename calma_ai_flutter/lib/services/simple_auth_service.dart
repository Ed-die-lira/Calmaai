import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SimpleAuthService extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;
  String? _userEmail;
  String? _userId;
  String? _token;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get userEmail => _userEmail;
  String? get userId => _userId;

  // Construtor
  SimpleAuthService() {
    _loadUserFromStorage();
  }

  // Carregar usuário do armazenamento seguro
  Future<void> _loadUserFromStorage() async {
    try {
      _isLoading = true;
      notifyListeners();

      _userEmail = await _storage.read(key: 'user_email');
      _userId = await _storage.read(key: 'user_id');
      _token = await _storage.read(key: 'auth_token');

      _isAuthenticated = _token != null;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Erro ao carregar dados do usuário: $e';
      notifyListeners();
    }
  }

  // Salvar usuário no armazenamento seguro
  Future<void> _saveUserToStorage() async {
    try {
      await _storage.write(key: 'user_email', value: _userEmail);
      await _storage.write(key: 'user_id', value: _userId);
      await _storage.write(key: 'auth_token', value: _token);
    } catch (e) {
      _error = 'Erro ao salvar dados do usuário: $e';
      notifyListeners();
    }
  }

  // Limpar dados do usuário
  Future<void> _clearUserFromStorage() async {
    try {
      await _storage.delete(key: 'user_email');
      await _storage.delete(key: 'user_id');
      await _storage.delete(key: 'auth_token');
    } catch (e) {
      _error = 'Erro ao limpar dados do usuário: $e';
      notifyListeners();
    }
  }

  // Login com e-mail e senha
  Future<bool> loginWithEmailAndPassword(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Aqui você faria uma chamada para seu backend
      final response = await http.post(
        Uri.parse('https://seu-backend.com/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _token = data['token'];
        _userEmail = email;
        _userId = data['userId'];
        _isAuthenticated = true;

        await _saveUserToStorage();

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final data = json.decode(response.body);
        _error = data['message'] ?? 'Erro ao fazer login';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Erro ao fazer login: $e';
      notifyListeners();
      return false;
    }
  }

  // Registro com e-mail e senha
  Future<bool> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Aqui você faria uma chamada para seu backend
      final response = await http.post(
        Uri.parse('https://seu-backend.com/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        _token = data['token'];
        _userEmail = email;
        _userId = data['userId'];
        _isAuthenticated = true;

        await _saveUserToStorage();

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final data = json.decode(response.body);
        _error = data['message'] ?? 'Erro ao registrar';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Erro ao registrar: $e';
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      _isAuthenticated = false;
      _userEmail = null;
      _userId = null;
      _token = null;

      await _clearUserFromStorage();

      notifyListeners();
    } catch (e) {
      _error = 'Erro ao fazer logout: $e';
      notifyListeners();
    }
  }

  // Obter token de autenticação
  Future<String?> getToken() async {
    return _token;
  }
}
