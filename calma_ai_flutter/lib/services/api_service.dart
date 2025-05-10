/**
 * Serviço para comunicação com a API
 */

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kReleaseMode;

// Importar modelos
import '../models/meditation.dart';
import '../models/category.dart';

class ApiService {
  // URL base da API
  final String baseUrl = kReleaseMode
      ? 'https://calmaai.onrender.com/api' // URL de produção
      : 'http://10.0.2.2:3000/api'; // URL para emulador Android

  // Token de autenticação
  final String? token;

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
      rethrow;
    }
  }

  // Obter todas as categorias de meditação
  Future<List<Category>> getMeditationCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/meditations/categories'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Category.fromJson(item)).toList();
      } else {
        throw Exception('Falha ao carregar categorias: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao obter categorias: $e');
      rethrow;
    }
  }

  // Obter meditações por categoria
  Future<List<Meditation>> getMeditationsByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/meditations/category/$category'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Meditation.fromJson(item)).toList();
      } else {
        throw Exception(
            'Falha ao carregar meditações da categoria: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao obter meditações da categoria: $e');
      rethrow;
    }
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
      rethrow;
    }
  }
}
