import 'package:flutter/material.dart';
import 'game_play_screen.dart';

class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SELECT MODE'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // RACE MODE BUTTON
            _buildModeCard(
              context,
              title: 'RACE MODE',
              subtitle: 'Classic Nokia high-speed tracking',
              icon: Icons.speed,
              color: Colors.redAccent,
              onTap: () => _navigateToGame(context, 'Race'),
            ),
            const SizedBox(height: 24),
            
            // PARKING MODE BUTTON
            _buildModeCard(
              context,
              title: 'PARKING MODE',
              subtitle: 'Precision obstacle alignment',
              icon: Icons.local_parking,
              color: Colors.cyan,
              onTap: () => _navigateToGame(context, 'Parking'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeCard(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToGame(BuildContext context, String mode) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GamePlayScreen(gameMode: mode),
      ),
    );
  }
}
