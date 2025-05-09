/**
 * Widget para exibir um card de meditação
 * Usado na tela inicial e na tela de meditações
 */

import 'package:flutter/material.dart';
import '../models/meditation.dart';

class MeditationCard extends StatelessWidget {
  final Meditation meditation;
  final VoidCallback onTap;
  
  const MeditationCard({
    super.key,
    required this.meditation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título da meditação
              Text(
                meditation.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2196F3),
                ),
              ),
              const SizedBox(height: 8),
              
              // Descrição da meditação
              Text(
                meditation.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              
              // Duração da meditação
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        meditation.duration,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  
                  // Botão de play
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF64B5F6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
