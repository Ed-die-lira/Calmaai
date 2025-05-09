/**
 * Modelo para posts da comunidade
 * Representa um post com título, conteúdo e informações de moderação
 */

import 'package:intl/intl.dart';

class Post {
  final String? id;
  final String userId;
  final String title;
  final String content;
  final bool moderationPassed;
  final double moderationScore;
  final DateTime createdAt;
  final DateTime updatedAt;

  Post({
    this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.moderationPassed,
    required this.moderationScore,
    required this.createdAt,
    required this.updatedAt,
  });

  // Construtor a partir de JSON
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['_id'],
      userId: json['userId'],
      title: json['title'],
      content: json['content'],
      moderationPassed: json['moderationPassed'] ?? false,
      moderationScore: json['moderationScore']?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] != null 
        ? DateTime.parse(json['createdAt']) 
        : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
        ? DateTime.parse(json['updatedAt']) 
        : DateTime.now(),
    );
  }

  // Converter para JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title': title,
      'content': content,
      'moderationPassed': moderationPassed,
      'moderationScore': moderationScore,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Formatar data de criação
  String get formattedCreatedAt {
    return DateFormat('dd/MM/yyyy - HH:mm').format(createdAt);
  }

  // Verificar se o post foi editado
  bool get wasEdited {
    return updatedAt.difference(createdAt).inSeconds > 1;
  }
}
