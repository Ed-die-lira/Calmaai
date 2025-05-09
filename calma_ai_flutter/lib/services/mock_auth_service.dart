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
}
