import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:disaster_link/presentation/theme/app_theme.dart';
import 'package:disaster_link/presentation/home/connectivity_banner.dart';

class VolunteerHomeScreen extends StatelessWidget {
  const VolunteerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Volunteer Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {},
          )
        ],
      ),
      body: Column(
        children: [
          const ConnectivityBanner(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Row(
                  children: [
                    Expanded(child: _StatCard(title: 'Pending', count: '12', color: AppTheme.secondary)),
                    SizedBox(width: 16),
                    Expanded(child: _StatCard(title: 'Accepted', count: '4', color: AppTheme.success)),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                const SizedBox(height: 16),
                _ActionTile(icon: Icons.list_alt, title: 'View Help Requests', onTap: () => context.push('/volunteer/requests')),
                const SizedBox(height: 12),
                _ActionTile(icon: Icons.add_location_alt, title: 'Add Resource Marker', onTap: () => context.push('/volunteer/add-marker')),
                const SizedBox(height: 12),
                _ActionTile(icon: Icons.map, title: 'Open Full Map', onTap: () => context.push('/volunteer/map')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String count;
  final Color color;
  const _StatCard({required this.title, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border(bottom: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        children: [
          Text(count, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _ActionTile({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: AppTheme.card,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: AppTheme.textPrimary),
      ),
      title: Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textSecondary),
    );
  }
}
