import 'package:flutter/foundation.dart';
import 'auth_service.dart';

class MockAuthService extends AuthService {
  MockAuthService() {
    // Não podemos acessar diretamente as variáveis privadas da classe pai
    // Vamos usar métodos protegidos ou públicos para configurar o estado

    // Simulando login bem-sucedido
    loginWithEmailAndPassword('teste@exemplo.com', 'senha123');
  }

  @override
  Future<bool> loginWithEmailAndPassword(String email, String password) async {
    // Sempre retorna sucesso para testes
    notifyListeners();
    return true;
  }

  @override
  Future<String?> getToken() async {
    // Sempre retorna um token de teste
    return 'mock-token-for-testing-123456';
  }
}
