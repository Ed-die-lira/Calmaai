/**
 * Modelo para meditação
 */

class Meditation {
  final String id;
  final String title;
  final String description;
  final String audioUrl;
  final int duration; // em segundos
  final String category;

  Meditation({
    required this.id,
    required this.title,
    required this.description,
    required this.audioUrl,
    required this.duration,
    required this.category,
  });

  factory Meditation.fromJson(Map<String, dynamic> json) {
    return Meditation(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      audioUrl: json['audioUrl'] ?? '',
      duration: json['duration'] ?? 0,
      category: json['category'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'audioUrl': audioUrl,
      'duration': duration,
      'category': category,
    };
  }
}
