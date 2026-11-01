import 'package:flutter/material.dart';
import 'mode_selection.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Nokia వైబ్ కోసం రెట్రో స్టైల్ టైటిల్
            const Text(
              'RALLY 3D',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
                letterSpacing: 4,
              ),
            ),
            const Text(
              'AI TRIBUTE',
              style: TextStyle(fontSize: 16, color: Colors.grey, letterSpacing: 2),
            ),
            const SizedBox(height: 60),

            // PLAY BUTTON
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ModeSelectionScreen()),
                );
              },
              child: const Text('START GAME', style: TextStyle(fontSize: 20, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
