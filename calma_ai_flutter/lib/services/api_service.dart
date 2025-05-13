/**
 * Serviço para comunicação com a API
 */

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/meditation.dart';

class ApiService {
  // URL base do servidor
  final String baseUrl = kReleaseMode
      ? 'https://calmaai.onrender.com' // URL de produção
      : 'http://10.0.2.2:3000'; // URL para emulador Android (localhost do host)

  // Token de autenticação (opcional)
  final String? token;

  // Construtor
  ApiService({this.token});

  // Headers para requisições autenticadas
  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Testar conexão com o servidor
  Future<bool> testConnection() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/'));
      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao testar conexão: $e');
      return false;
    }
  }

  // Testar CORS
  Future<bool> testCors() async {
    try {
      final response =
          await http.options(Uri.parse('$baseUrl/api/meditations'));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print('Erro ao testar CORS: $e');
      return false;
    }
  }

  // Obter lista de meditações
  Future<List<Meditation>> getMeditations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/meditations'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Meditation.fromJson(item)).toList();
      } else {
        print('Erro ao obter meditações: ${response.statusCode}');
        // Fallback para dados locais em caso de erro
        return _getLocalMeditations();
      }
    } catch (e) {
      print('Erro ao obter meditações: $e');
      // Fallback para dados locais em caso de erro
      return _getLocalMeditations();
    }
  }

  // Dados locais para fallback
  List<Meditation> _getLocalMeditations() {
    return [
      Meditation(
        id: 'calma_meditacao',
        title: 'Meditação para Calma',
        description: 'Uma meditação para acalmar a mente e o corpo',
        audioUrl: '$baseUrl/static/Calma/calma.mp3',
        duration: 300,
        category: 'calma',
      ),
      Meditation(
        id: 'foco_meditacao',
        title: 'Meditação para Foco',
        description: 'Aumente sua concentração e foco',
        audioUrl: '$baseUrl/static/Foco/foco.mp3',
        duration: 600,
        category: 'foco',
      ),
      Meditation(
        id: 'sono_meditacao',
        title: 'Meditação para Sono',
        description: 'Relaxe e prepare-se para uma boa noite de sono',
        audioUrl: '$baseUrl/static/Sono/sono.mp3',
        duration: 900,
        category: 'sono',
      ),
      Meditation(
        id: 'respiracao_exercicio',
        title: 'Exercício de Respiração',
        description: 'Respire fundo e relaxe',
        audioUrl: '$baseUrl/static/Respiracao/respiracao.mp3',
        duration: 300,
        category: 'respiracao',
      ),
    ];
  }

  // Sugerir meditação com base no humor
  Future<Meditation> suggestMeditation(String mood) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/meditations/suggest'),
        headers: _headers,
        body: json.encode({'mood': mood}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Meditation.fromJson(data['suggestion']);
      } else {
        print('Erro ao sugerir meditação: ${response.statusCode}');
        // Fallback para sugestão local
        return _getSuggestionByMood(mood);
      }
    } catch (e) {
      print('Erro ao sugerir meditação: $e');
      // Fallback para sugestão local
      return _getSuggestionByMood(mood);
    }
  }

  // Sugestão local baseada no humor
  Meditation _getSuggestionByMood(String mood) {
    final lowerMood = mood.toLowerCase();

    if (lowerMood.contains('ansioso') ||
        lowerMood.contains('nervoso') ||
        lowerMood.contains('estressado')) {
      return _getLocalMeditations()[0]; // Calma
    } else if (lowerMood.contains('cansado') ||
        lowerMood.contains('distraído')) {
      return _getLocalMeditations()[1]; // Foco
    } else if (lowerMood.contains('insônia') || lowerMood.contains('agitado')) {
      return _getLocalMeditations()[2]; // Sono
    } else {
      // Escolha aleatória se não houver correspondência
      final index = DateTime.now().millisecond % 3;
      return _getLocalMeditations()[index];
    }
  }
}
