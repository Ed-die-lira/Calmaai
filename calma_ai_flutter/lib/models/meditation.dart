/**
 * Modelo para meditações
 * Representa uma meditação com título, descrição e URL do áudio
 */

class Meditation {
  final String id;
  final String title;
  final String description;
  final String audioUrl;
  final String duration;

  Meditation({
    required this.id,
    required this.title,
    required this.description,
    required this.audioUrl,
    required this.duration,
  });

  // Construtor a partir de JSON
  factory Meditation.fromJson(Map<String, dynamic> json) {
    return Meditation(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      audioUrl: json['audioUrl'],
      duration: json['duration'],
    );
  }

  // Converter para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'audioUrl': audioUrl,
      'duration': duration,
    };
  }
}
