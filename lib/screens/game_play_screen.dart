import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../game/rally_game.dart';

class GamePlayScreen extends StatefulWidget {
  final String gameMode;
  final int level;

  const GamePlayScreen({
    super.key,
    required this.gameMode,
    this.level = 1,
  });

  @override
  State<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends State<GamePlayScreen> {
  late RallyGame _rallyGame;
  bool _showKeypadSettings = false;

  @override
  void initState() {
    super.initState();
    _rallyGame = RallyGame(gameMode: widget.gameMode, level: widget.level);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Hardware Accelerated Flame Canvas Layer
          GestureDetector(
            onPanUpdate: (details) {
              if (_rallyGame.useVirtualKeypad) return;
              _rallyGame.handleSwipe(details.delta);
            },
            child: GameWidget(
              game: _rallyGame,
              overlayBuilderMap: {
                'GameOverMenu': (context, RallyGame game) {
                  return const SizedBox.shrink();
                },
              },
            ),
          ),

          // 2. Real-time Live Score Dashboard Display
          if (widget.gameMode == 'Race')
            StreamBuilder(
              stream: Stream.periodic(const Duration(milliseconds: 50)),
              builder: (context, snapshot) {
                return Positioned(
                  top: 45,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'SCORE: ${_rallyGame.score.toInt()}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

          // 3. Navigation Controls - Floating Back Route Trigger
          Positioned(
            top: 45,
            left: 20,
            child: FloatingActionButton.small(
              heroTag: 'parkingGameBackBtnTag',
              backgroundColor: Colors.black54,
              child: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // 4. Configuration Controls - Menu Settings Toggle Gear Link
          Positioned(
            top: 45,
            right: 20,
            child: FloatingActionButton.small(
              heroTag: 'parkingGameSettingsBtnTag',
              backgroundColor: Colors.black54,
              child: const Icon(Icons.settings, color: Colors.white),
              onPressed: () {
                setState(() {
                  _showKeypadSettings = !_showKeypadSettings;
                });
              },
            ),
          ),

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

          // 5. Classic Legacy 2-4-6-8 Tactile Virtual Input Pad Overlay Layer
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

          // 6. Enhanced Game Over Popup Layout Box displaying High Scores
          StreamBuilder(
            stream: Stream.periodic(const Duration(milliseconds: 100)),
            builder: (context, snapshot) {
              if (!_rallyGame.isGameOver) return const SizedBox.shrink();

              return Container(
                color: Colors.black.withOpacity(0.85),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'GAME OVER',
                        style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.redAccent, letterSpacing: 3),
                      ),
                      const SizedBox(height: 20),
                      if (widget.gameMode == 'Race') ...[
                        Text(
                          'YOUR SCORE: ${_rallyGame.score.toInt()}',
                          style: const TextStyle(fontSize: 20, color: Colors.white),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'BEST HIGH SCORE: ${_rallyGame.highScore}',
                          style: const TextStyle(fontSize: 18, color: Colors.amber, fontWeight: FontWeight.w600),
                        ),
                      ],
                      const SizedBox(height: 40),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 15),
                        ),
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        label: const Text('PLAY AGAIN', style: TextStyle(fontSize: 18, color: Colors.white)),
                        onPressed: () {
                          setState(() {
                            _rallyGame.resetGame();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          StreamBuilder(
            stream: Stream.periodic(const Duration(milliseconds: 100)),
            builder: (context, snapshot) {
              if (!_rallyGame.isLevelCleared) {
                return const SizedBox.shrink();
              }

              return Container(
                color: Colors.black.withOpacity(0.85),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle, size: 80, color: Colors.greenAccent),
                      const SizedBox(height: 15),
                      Text(
                        'LEVEL ${_rallyGame.level} CLEARED!',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.greenAccent,
                          letterSpacing: 2,
                        ),
                      ),
                      const Text(
                        'Perfect Parking Execution',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 35,
                            vertical: 15,
                          ),
                        ),
                        icon: const Icon(Icons.skip_next, color: Colors.white),
                        label: Text(
                          _rallyGame.level < 6
                              ? 'NEXT LEVEL'
                              : 'GAME COMPLETED!',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          if (_rallyGame.level < 6) {
                            setState(_rallyGame.nextLevel);
                          } else {
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

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
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.grey.shade700,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
            Text(
              subLabel,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
                height: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}