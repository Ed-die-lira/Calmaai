/**
 * Serviço para comunicação com a API
 */

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/meditation.dart';

class ApiService {
  final String? token;

  // URL base da API
  String get baseUrl {
    if (kIsWeb) {
      // Para web, usar localhost ou a URL de produção
      return 'https://calmaai.onrender.com/api';
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
    if (kIsWeb) {
      // Para web, usar localhost ou a URL de produção
      return 'https://calmaai.onrender.com';
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
        throw Exception('Falha ao carregar meditações: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao obter meditações: $e');
      // Para testes, retornar dados fictícios se a API falhar
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
}
