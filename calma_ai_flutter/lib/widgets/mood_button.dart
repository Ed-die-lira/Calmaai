/**
 * Widget para botão de humor
 * Usado na tela de meditações para selecionar o humor atual
 */

import 'package:flutter/material.dart';

class MoodButton extends StatelessWidget {
  final String mood;
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;
  
  const MoodButton({
    super.key,
    required this.mood,
    required this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF64B5F6) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF64B5F6),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 8),
            Text(
              mood,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : const Color(0xFF64B5F6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
