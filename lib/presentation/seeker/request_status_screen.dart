import 'package:flutter/material.dart';
import 'package:disaster_link/presentation/theme/app_theme.dart';

class RequestStatusScreen extends StatelessWidget {
  const RequestStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Status')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.check_circle_outline, size: 80, color: AppTheme.success),
            const SizedBox(height: 16),
            const Text('Request Received', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            const Text('Token: REQ-12345', style: TextStyle(fontSize: 16, color: AppTheme.secondary)),
            const SizedBox(height: 40),
            _buildTimelineStep('Submitted', true, true),
            _buildTimelineStep('Volunteer Accepted', false, false),
            _buildTimelineStep('Resolved', false, false, isLast: true),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStep(String title, bool isActive, bool isCompleted, {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted ? AppTheme.success : (isActive ? AppTheme.secondary : AppTheme.card),
                shape: BoxShape.circle,
              ),
              child: isCompleted ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
            ),
            if (!isLast)
              Container(width: 2, height: 40, color: isCompleted ? AppTheme.success : AppTheme.card),
          ],
        ),
        const SizedBox(width: 16),
        Text(title, style: TextStyle(fontSize: 18, color: isActive || isCompleted ? AppTheme.textPrimary : AppTheme.textSecondary)),
      ],
    );
  }
}
