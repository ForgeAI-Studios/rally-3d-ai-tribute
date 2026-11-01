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
  bool _showKeypadSettings = false;

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
          // టచ్ స్క్రీన్ స్వైప్ కంట్రోల్స్ కోసం GestureDetector వాడుతున్నాం
          GestureDetector(
            onPanUpdate: (details) {
              if (_rallyGame.useVirtualKeypad) return; // కీప్యాడ్ మోడ్ ఉంటే టచ్ పనిచేయదు
              
              if (details.delta.dx < -5) _rallyGame.moveLeft();
              if (details.delta.dx > 5) _rallyGame.moveRight();
              if (details.delta.dy < -5) _rallyGame.moveUp();
              if (details.delta.dy > 5) _rallyGame.moveDown();
            },
            child: GameWidget(game: _rallyGame),
          ),

          // టాప్ లెఫ్ట్ - బ్యాక్ బటన్
          Positioned(
            top: 45,
            left: 20,
            child: FloatingActionButton.small(
              backgroundColor: Colors.black54,
              child: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // టాప్ రైట్ - కంట్రోల్స్ సెట్టింగ్స్ బటన్
          Positioned(
            top: 45,
            right: 20,
            child: FloatingActionButton.small(
              backgroundColor: Colors.black54,
              child: const Icon(Icons.settings, color: Colors.white),
              onPressed: () {
                setState(() {
                  _showKeypadSettings = !_showKeypadSettings;
                });
              },
            ),
          ),

          // సెట్టింగ్స్ పాప్-అప్ ప్యానెల్
          if (_showKeypadSettings)
            Positioned(
              top: 100,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    const Text("Nokia Keypad Overlay: ", style: TextStyle(color: Colors.white)),
                    Switch(
                      value: _rallyGame.useVirtualKeypad,
                      onChanged: (value) {
                        setState(() {
                          _rallyGame.useVirtualKeypad = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

          // వర్చువల్ కీప్యాడ్ లేఅవుట్ (సెట్టింగ్స్ లో ఆన్ చేస్తేనే కనిపిస్తుంది)
          if (_rallyGame.useVirtualKeypad)
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
                      _buildKypadButton(label: '2', subLabel: '▲', onTap: () => _rallyGame.moveUp()),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildKypadButton(label: '4', subLabel: '◀', onTap: () => _rallyGame.moveLeft()),
                          const SizedBox(width: 25),
                          _buildKypadButton(label: '6', subLabel: '▶', onTap: () => _rallyGame.moveRight()),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildKypadButton(label: '8', subLabel: '▼', onTap: () => _rallyGame.moveDown()),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildKypadButton({required String label, required String subLabel, required VoidCallback onTap}) {
    return GestureDetector(
      onTapDown: (_) => onTap(),
      child: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade700, width: 1.5),
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
