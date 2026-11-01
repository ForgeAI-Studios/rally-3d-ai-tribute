import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../game/rally_game.dart';

class GamePlayScreen extends StatefulWidget {
  final String gameMode;

  const GamePlayScreen({super.key, required this.gameMode});

  @override
  State<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends State<GamePlayScreen> {
  late RallyGame _rallyGame;

  @override
  void initState() {
    super.initState();
    _rallyGame = RallyGame(gameMode: widget.gameMode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Layer 1: Hardware-Accelerated Flame Game Canvas
          GameWidget(game: _rallyGame),

          // Layer 2: Top Floating Back Button
          Positioned(
            top: 45,
            left: 20,
            child: FloatingActionButton.small(
              backgroundColor: Colors.black54,
              child: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Layer 3: Nokia Retro Virtual Keypad Controller Overlap
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Container(
                width: 200,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade800, width: 2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Key '2' - Accelerate Up
                    _buildKypadButton(label: '2', subLabel: '▲', onTap: () {
                      debugPrint("Keypad: 2 Pressed");
                      // Will bind to player car's upward vector velocity acceleration acceleration logic
                    }),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Key '4' - Steer Left
                        _buildKypadButton(label: '4', subLabel: '◀', onTap: () {
                          debugPrint("Keypad: 4 Pressed");
                          // Will trigger player car horizontal steering shift left adjustments
                        }),
                        const SizedBox(width: 25),
                        // Key '6' - Steer Right
                        _buildKypadButton(label: '6', subLabel: '▶', onTap: () {
                          debugPrint("Keypad: 6 Pressed");
                          // Will trigger player car horizontal steering shift right adjustments
                        }),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Key '8' - Reverse / Brake Down
                    _buildKypadButton(label: '8', subLabel: '▼', onTap: () {
                      debugPrint("Keypad: 8 Pressed");
                      // Will bind to deceleration / reverse mechanics
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget to construct authentic looking numerical buttons
  Widget _buildKypadButton({
    required String label,
    required String subLabel,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTapDown: (_) => onTap(),
      child: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade700, width: 1.5),
          boxShadow: const [
            BoxShadow(color: Colors.black38, offset: Offset(2, 2), blurRadius: 4),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber)),
            Text(subLabel, style: const TextStyle(fontSize: 10, color: Colors.grey, height: 0.8)),
          ],
        ),
      ),
    );
  }
}
