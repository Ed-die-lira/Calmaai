/**
 * Modelo para meditação
 */

class Meditation {
  final String id;
  final String title;
  final String description;
  final String audioUrl;
  final String category;
  final String duration;

  Meditation({
    required this.id,
    required this.title,
    required this.description,
    required this.audioUrl,
    required this.category,
    required this.duration,
  });

  factory Meditation.fromJson(Map<String, dynamic> json) {
    return Meditation(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      audioUrl: json['audioUrl'] ?? '',
      category: json['category'] ?? '',
      duration: json['duration'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'audioUrl': audioUrl,
      'category': category,
      'duration': duration,
    };
  }
}
