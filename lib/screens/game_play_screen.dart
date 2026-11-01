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
          // 1. గేమ్ కాన్వాస్ లూప్
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

          // 2. టాప్ లెఫ్ట్ - బ్యాక్ బటన్
          Positioned(
            top: 45,
            left: 20,
            child: FloatingActionButton.small(
              backgroundColor: Colors.black54,
              child: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // 3. టాప్ రైట్ - సెట్టింగ్స్ బటన్
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

          // సెట్టింగ్స్ ప్యానెల్
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

          // 4. వర్చువల్ కీప్యాడ్ లేఅవుట్
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

          // 5. నిరంతరం గేమ్ ఓవర్ స్టేట్‌ను గమనించి రీస్టార్ట్ UI చూపించే మెకానిజం
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
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        ),
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        label: const Text('RESTART', style: TextStyle(fontSize: 18, color: Colors.white)),
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
