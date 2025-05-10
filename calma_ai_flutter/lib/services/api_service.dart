/**
 * Serviço para comunicação com a API
 */

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kReleaseMode;

// Importar modelos
import '../models/meditation.dart';
import '../models/category.dart';
import '../models/diary_entry.dart';
import '../models/post.dart';

class ApiService {
  // URL base da API
  final String baseUrl;

  // Token de autenticação
  final String? token;

  ApiService({this.token, String? customBaseUrl})
      : baseUrl = customBaseUrl ??
            (kReleaseMode
                ? 'https://calmaai.onrender.com/api' // URL de produção
                : 'http://10.0.2.2:3000/api'); // URL para emulador Android

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

  // Verificar conexão com o servidor
  Future<bool> checkConnection() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/health'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao verificar conexão: $e');
      return false;
    }
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

  // Obter posts da comunidade
  Future<List<Post>> getPosts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/community/posts'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Post.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao carregar posts: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao carregar posts: $e');
      rethrow;
    }
  }

  // Criar novo post
  Future<Post> createPost(
      {required String userId,
      required String title,
      required String content}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/community/posts'),
        headers: _headers,
        body:
            json.encode({'userId': userId, 'title': title, 'content': content}),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Post.fromJson(data);
      } else {
        throw Exception('Falha ao criar post: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao criar post: $e');
      rethrow;
    }
  }

  // Obter histórico do diário
  Future<List<DiaryEntry>> getDiaryHistory(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/diary/history/$userId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => DiaryEntry.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao carregar histórico: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao carregar histórico: $e');
      rethrow;
    }
  }

  // Obter estatísticas do diário
  Future<Map<String, dynamic>> getDiaryStats(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/diary/stats/$userId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Falha ao carregar estatísticas: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao carregar estatísticas: $e');
      rethrow;
    }
  }

  // Salvar entrada do diário
  Future<DiaryEntry> saveDiaryEntry(String userId, String content) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/diary/entries'),
        headers: _headers,
        body: json.encode({
          'userId': userId,
          'content': content,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return DiaryEntry.fromJson(data);
      } else {
        throw Exception('Falha ao salvar entrada: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao salvar entrada: $e');
      rethrow;
    }
  }
}
