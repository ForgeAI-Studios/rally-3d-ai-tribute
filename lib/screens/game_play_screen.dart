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
    // Instantiate our custom Flame game runtime controller instance
    _rallyGame = RallyGame(gameMode: widget.gameMode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. The Real-time Flame Game Loop Rendering Canvas Layer
          GameWidget(game: _rallyGame),

          // 2. Head-Up Display (HUD) & Exit Overlay Control Route
          Positioned(
            top: 45,
            left: 20,
            child: FloatingActionButton.small(
              backgroundColor: Colors.black54,
              child: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
