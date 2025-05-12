/**
 * Serviço para comunicação com a API
 */

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/meditation.dart';

class ApiService {
  final String? token;
  bool _useFallbackUrls = false;

  // URL base da API
  String get baseUrl {
    if (_useFallbackUrls) {
      // Usar URL alternativa se a principal falhar
      return 'https://calmaai.onrender.com/api';
    }

    if (kIsWeb) {
      // Para web, tentar localhost primeiro (para desenvolvimento local)
      return kReleaseMode
          ? 'https://calmaai.onrender.com/api'
          : 'http://localhost:3000/api';
    } else if (kReleaseMode) {
      // Para release em dispositivos móveis
      return 'https://calmaai.onrender.com/api';
    } else {
      // Para debug em emuladores
      return 'http://10.0.2.2:3000/api';
    }
  }

  // URL para arquivos estáticos
  String get staticUrl {
    if (_useFallbackUrls) {
      // Usar URL alternativa se a principal falhar
      return 'https://calmaai.onrender.com';
    }

    if (kIsWeb) {
      // Para web, tentar localhost primeiro (para desenvolvimento local)
      return kReleaseMode
          ? 'https://calmaai.onrender.com'
          : 'http://localhost:3000';
    } else if (kReleaseMode) {
      // Para release em dispositivos móveis
      return 'https://calmaai.onrender.com';
    } else {
      // Para debug em emuladores
      return 'http://10.0.2.2:3000';
    }
  }

  ApiService({this.token});

  // Headers para requisições autenticadas
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Obter todas as meditações
  Future<List<Meditation>> getMeditations() async {
    try {
      print('Tentando obter meditações de: $baseUrl/meditations');
      final response = await http.get(
        Uri.parse('$baseUrl/meditations'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Meditation.fromJson(item)).toList();
      } else {
        print('Erro HTTP: ${response.statusCode}');
        throw Exception('Falha ao carregar meditações: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao obter meditações: $e');

      // Se for a primeira tentativa, tentar com URL alternativa
      if (!_useFallbackUrls) {
        _useFallbackUrls = true;
        print('Tentando novamente com URL alternativa: $baseUrl/meditations');
        return getMeditations();
      }

      // Se ainda falhar, usar dados fictícios
      print('Usando dados fictícios após falha na comunicação');
      return _getMockMeditations();
    }
  }

  // Dados fictícios para testes
  List<Meditation> _getMockMeditations() {
    return [
      Meditation(
        id: 'calma_1',
        title: 'Meditação para Calma',
        description:
            'Acalme sua mente e reduza a ansiedade com esta meditação guiada.',
        audioUrl:
            'https://www2.cs.uic.edu/~i101/SoundFiles/StarWars3.wav', // URL pública para teste
        category: 'Calma',
        duration: '10 min',
      ),
      Meditation(
        id: 'foco_1',
        title: 'Meditação para Foco',
        description: 'Aumente sua concentração e foco com esta meditação.',
        audioUrl:
            'https://www2.cs.uic.edu/~i101/SoundFiles/ImperialMarch60.wav', // URL pública para teste
        category: 'Foco',
        duration: '15 min',
      ),
      Meditation(
        id: 'sono_1',
        title: 'Meditação para Sono',
        description: 'Relaxe e prepare-se para uma noite de sono tranquila.',
        audioUrl:
            'https://www2.cs.uic.edu/~i101/SoundFiles/CantinaBand3.wav', // URL pública para teste
        category: 'Sono',
        duration: '20 min',
      ),
      Meditation(
        id: 'respiracao_1',
        title: 'Exercício de Respiração',
        description:
            'Pratique a respiração consciente para reduzir o estresse.',
        audioUrl:
            'https://www2.cs.uic.edu/~i101/SoundFiles/PinkPanther30.wav', // URL pública para teste
        category: 'Respiração',
        duration: '5 min',
      ),
    ];
  }

  // Sugerir meditação com base no humor
  Future<Meditation> suggestMeditation(String mood) async {
    try {
      print('Tentando sugerir meditação para humor: $mood');
      final response = await http.post(
        Uri.parse('$baseUrl/meditations/suggest'),
        headers: _headers,
        body: json.encode({'mood': mood}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Meditation.fromJson(data['suggestion']);
      } else {
        throw Exception('Falha ao sugerir meditação: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao sugerir meditação: $e');

      // Se for a primeira tentativa, tentar com URL alternativa
      if (!_useFallbackUrls) {
        _useFallbackUrls = true;
        print('Tentando novamente com URL alternativa');
        return suggestMeditation(mood);
      }

      // Mapear humor para meditação específica dos dados fictícios
      final meditations = _getMockMeditations();

      if (mood.toLowerCase().contains('ansioso')) {
        return meditations[0]; // Calma
      } else if (mood.toLowerCase().contains('cansado')) {
        return meditations[1]; // Foco
      } else {
        return meditations[2]; // Sono
      }
    }
  }

  // Obter URL completa para um arquivo de áudio
  String getFullAudioUrl(String audioPath) {
    if (audioPath.startsWith('http')) {
      return audioPath;
    } else {
      return '$staticUrl$audioPath';
    }
  }

  // Método para testar a conexão com o backend
  Future<bool> testConnection() async {
    try {
      print('Testando conexão com: $baseUrl');
      final response = await http.get(
        Uri.parse('$baseUrl'),
        headers: _headers,
      );

      print('Resposta do teste de conexão: ${response.statusCode}');
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print('Erro no teste de conexão: $e');

      // Se for a primeira tentativa, tentar com URL alternativa
      if (!_useFallbackUrls) {
        _useFallbackUrls = true;
        print('Tentando novamente com URL alternativa');
        return testConnection();
      }

      return false;
    }
  }

  // Método para testar especificamente o CORS
  Future<Map<String, dynamic>> testCors() async {
    try {
      print('Testando CORS com: $baseUrl/meditations/cors-test');
      final response = await http.get(
        Uri.parse('$baseUrl/meditations/cors-test'),
        headers: _headers,
      );

      print('Resposta do teste CORS: ${response.statusCode}');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else {
        throw Exception('Falha no teste CORS: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro no teste CORS: $e');

      // Se for a primeira tentativa, tentar com URL alternativa
      if (!_useFallbackUrls) {
        _useFallbackUrls = true;
        print('Tentando novamente com URL alternativa');
        return testCors();
      }

      return {
        'success': false,
        'error': e.toString(),
        'message':
            'Falha no teste CORS. Verifique se o servidor está configurado corretamente.'
      };
    }
  }
}
