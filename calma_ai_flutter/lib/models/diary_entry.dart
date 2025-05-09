/**
 * Modelo para entradas do diário
 * Representa uma entrada do diário com texto e análise de sentimentos
 */

import 'package:intl/intl.dart';

class DiaryEntry {
  final String? id;
  final String userId;
  final String text;
  final String sentiment;
  final double sentimentScore;
  final DateTime date;

  DiaryEntry({
    this.id,
    required this.userId,
    required this.text,
    required this.sentiment,
    required this.sentimentScore,
    required this.date,
  });

  // Construtor a partir de JSON
  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      id: json['_id'],
      userId: json['userId'],
      text: json['text'],
      sentiment: json['sentiment'],
      sentimentScore: json['sentimentScore'].toDouble(),
      date: json['date'] != null 
        ? DateTime.parse(json['date']) 
        : DateTime.now(),
    );
  }

  // Converter para JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'text': text,
      'sentiment': sentiment,
      'sentimentScore': sentimentScore,
      'date': date.toIso8601String(),
    };
  }

  // Obter emoji com base no sentimento
  String get sentimentEmoji {
    switch (sentiment) {
      case 'positive':
        return '😊';
      case 'negative':
        return '😔';
      case 'neutral':
        return '😐';
      default:
        return '❓';
    }
  }

  // Obter cor com base no sentimento
  int get sentimentColor {
    switch (sentiment) {
      case 'positive':
        return 0xFF81C784; // Verde
      case 'negative':
        return 0xFFE57373; // Vermelho
      case 'neutral':
        return 0xFF90CAF9; // Azul
      default:
        return 0xFF9E9E9E; // Cinza
    }
  }

  // Formatar data
  String get formattedDate {
    return DateFormat('dd/MM/yyyy - HH:mm').format(date);
  }
}
