/**
 * Modelo para categoria de meditação
 */

import 'meditation.dart';

class Category {
  final String id;
  final String name;
  final int count;
  final List<Meditation> meditations;

  Category({
    required this.id,
    required this.name,
    required this.count,
    required this.meditations,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    List<Meditation> meditationList = [];
    
    if (json['meditations'] != null) {
      meditationList = (json['meditations'] as List)
          .map((item) => Meditation.fromJson(item))
          .toList();
    }
    
    return Category(
      id: json['id'],
      name: json['name'],
      count: json['count'],
      meditations: meditationList,
    );
  }
}