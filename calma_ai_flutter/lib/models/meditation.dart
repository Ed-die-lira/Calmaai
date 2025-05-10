/**
 * Modelo para meditação
 */

class Meditation {
  final String id;
  final String title;
  final String description;
  final String audioUrl;
  final String duration;
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
      id: json['id'],
      title: json['title'],
      description: json['description'],
      audioUrl: json['audioUrl'],
      duration: json['duration'],
      category: json['category'] ?? '',
    );
  }
}
