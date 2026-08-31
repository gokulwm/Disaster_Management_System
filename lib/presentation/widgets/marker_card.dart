import 'package:flutter/material.dart';
import 'package:disaster_link/presentation/theme/app_theme.dart';

class MarkerCard extends StatelessWidget {
  final String title;
  final String description;
  const MarkerCard({super.key, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          Text(description, style: const TextStyle(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}
