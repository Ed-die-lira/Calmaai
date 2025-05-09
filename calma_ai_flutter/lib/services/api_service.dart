/**
 * Serviço para comunicação com a API do backend
 * Fornece métodos para todas as operações com o servidor
 */

import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:http/http.dart' as http;
import 'dart:convert';

// Importar modelos
import '../models/meditation.dart';
import '../models/diary_entry.dart';
import '../models/post.dart';

class ApiService {
  final String? token;
  final http.Client? client;

  // URL base da API - ajustar para produção
  final String baseUrl;

  ApiService({
    required this.token,
    this.client,
    String? customBaseUrl,
  }) : baseUrl = customBaseUrl ??
            (kReleaseMode
                ? 'https://calma-ai-backend.onrender.com/api' // URL de produção
                : 'http://10.0.2.2:3000/api'); // URL para emulador Android

  // Cabeçalhos HTTP com token de autenticação
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': token != null ? 'Bearer $token' : '',
      };

  // Tratar erros de resposta
  void _handleError(http.Response response) {
    if (response.statusCode >= 400) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Erro na requisição');
    }
  }

  // === MEDITAÇÕES ===

  // Obter lista de meditações
  Future<List<Meditation>> getMeditations() async {
    final response = await http.get(
      Uri.parse('$baseUrl/meditations'),
      headers: _headers,
    );

    _handleError(response);

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Meditation.fromJson(json)).toList();
  }

  // Obter meditação por ID
  Future<Meditation> getMeditationById(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/meditations/$id'),
      headers: _headers,
    );

    _handleError(response);

    final data = jsonDecode(response.body);
    return Meditation.fromJson(data);
  }

  // Sugerir meditação com base no humor
  Future<Meditation> suggestMeditation(String mood) async {
    final response = await http.post(
      Uri.parse('$baseUrl/meditations/suggest'),
      headers: _headers,
      body: jsonEncode({'mood': mood}),
    );

    _handleError(response);

    final data = jsonDecode(response.body);
    return Meditation.fromJson(data['suggestion']);
  }

  // === DIÁRIO ===

  // Salvar entrada no diário
  Future<DiaryEntry> saveDiaryEntry(String userId, String text) async {
    final response = await http.post(
      Uri.parse('$baseUrl/diary'),
      headers: _headers,
      body: jsonEncode({
        'userId': userId,
        'text': text,
      }),
    );

    _handleError(response);

    final data = jsonDecode(response.body);
    return DiaryEntry.fromJson(data['entry']);
  }

  // Obter histórico do diário
  Future<List<DiaryEntry>> getDiaryHistory(String userId,
      {int limit = 30, int skip = 0}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/diary/history/$userId?limit=$limit&skip=$skip'),
      headers: _headers,
    );

    _handleError(response);

    final data = jsonDecode(response.body);
    final List<dynamic> entries = data['entries'];
    return entries.map((json) => DiaryEntry.fromJson(json)).toList();
  }

  // Obter estatísticas do diário
  Future<Map<String, dynamic>> getDiaryStats(String userId,
      {int days = 30}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/diary/stats/$userId?days=$days'),
      headers: _headers,
    );

    _handleError(response);

    return jsonDecode(response.body);
  }

  // === COMUNIDADE ===

  // Criar post
  Future<Post> createPost(String userId, String title, String content) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts'),
      headers: _headers,
      body: jsonEncode({
        'userId': userId,
        'title': title,
        'content': content,
      }),
    );

    _handleError(response);

    final data = jsonDecode(response.body);
    return Post.fromJson(data['post']);
  }

  // Obter lista de posts
  Future<List<Post>> getPosts({int limit = 20, int skip = 0}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/posts?limit=$limit&skip=$skip'),
      headers: _headers,
    );

    _handleError(response);

    final data = jsonDecode(response.body);
    final List<dynamic> posts = data['posts'];
    return posts.map((json) => Post.fromJson(json)).toList();
  }

  // Obter posts de um usuário
  Future<List<Post>> getUserPosts(String userId,
      {int limit = 20, int skip = 0}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/posts/user/$userId?limit=$limit&skip=$skip'),
      headers: _headers,
    );

    _handleError(response);

    final data = jsonDecode(response.body);
    final List<dynamic> posts = data['posts'];
    return posts.map((json) => Post.fromJson(json)).toList();
  }
}
