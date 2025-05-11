import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';

class MockAuthService extends AuthService {
  @override
  User? get user => null;

  @override
  bool get isAuthenticated => true;

  @override
  Future<String?> getToken() async {
    return 'mock-token-for-testing';
  }

  @override
  Future<bool> loginWithEmailAndPassword(String email, String password) async {
    // Simular login bem-sucedido
    print('Mock login com: $email');
    return true;
  }

  @override
  Future<bool> registerWithEmailAndPassword(
      String email, String password) async {
    // Simular registro bem-sucedido
    print('Mock registro com: $email');
    return true;
  }

  @override
  Future<void> logout() async {
    // Simular logout
    print('Mock logout');
  }
}
