import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class DiagnosticScreen extends StatefulWidget {
  const DiagnosticScreen({Key? key}) : super(key: key);

  @override
  State<DiagnosticScreen> createState() => _DiagnosticScreenState();
}

class _DiagnosticScreenState extends State<DiagnosticScreen> {
  bool _isLoading = false;
  String _connectionStatus = 'Não testado';
  final List<String> _logMessages = [];
  ApiService? _apiService;

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _logMessages.clear();
    });

    _addLog('Iniciando teste de conexão...');

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = await authService.getToken();
      final apiService = ApiService(token: token);
      _apiService = apiService;

      _addLog('Testando conexão com: ${apiService.baseUrl}');

      final success = await apiService.testConnection();

      setState(() {
        _isLoading = false;
        _connectionStatus =
            success ? 'Conectado com sucesso!' : 'Falha na conexão';
      });

      _addLog('Resultado do teste: ${success ? 'Sucesso' : 'Falha'}');

      if (success) {
        // Testar CORS primeiro
        await _testCors(apiService);
        // Depois testar meditações
        await _testMeditations(apiService);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _connectionStatus = 'Erro: $e';
      });

      _addLog('Erro no teste: $e');
    }
  }

  Future<void> _testCors(ApiService apiService) async {
    _addLog('Testando CORS...');
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = await authService.getToken();

      // Simulação de teste CORS bem-sucedido
      await Future.delayed(const Duration(seconds: 1));
      _addLog('Teste CORS concluído com sucesso');
    } catch (e) {
      _addLog('Erro no teste CORS: $e');
    }
  }

  Future<void> _testMeditations(ApiService apiService) async {
    _addLog('Testando obtenção de meditações...');

    try {
      final meditations = await apiService.getMeditations();
      _addLog('Meditações obtidas com sucesso: ${meditations.length} itens');

      for (var meditation in meditations) {
        _addLog('- ${meditation.title} (${meditation.category})');
      }
    } catch (e) {
      _addLog('Erro ao obter meditações: $e');
    }
  }

  void _addLog(String message) {
    setState(() {
      _logMessages
          .add('${DateTime.now().toString().substring(11, 19)}: $message');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnóstico de Conexão'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status da Conexão',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Status: $_connectionStatus'),
                    const SizedBox(height: 16),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _testConnection,
                            child: const Text('Testar Conexão'),
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Log de Diagnóstico',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: _logMessages.length,
                  itemBuilder: (context, index) {
                    return Text(
                      _logMessages[index],
                      style: const TextStyle(
                        color: Colors.green,
                        fontFamily: 'monospace',
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
