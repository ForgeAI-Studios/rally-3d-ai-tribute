import 'package:flame/game.dart';
import 'package:flame/input.dart'; // కీబోర్డ్ ఈవెంట్స్ కోసం
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RallyGame extends FlameGame with KeyboardEvents {
  final String gameMode;
  
  // డిఫాల్ట్‌గా టచ్ స్క్రీన్ కంట్రోల్స్ ఆన్ (Settings లో మార్చుకోవచ్చు)
  bool useVirtualKeypad = false; 

  RallyGame({required this.gameMode});

  @override
  Future<void> onLoad() async {
    super.onLoad();
    debugPrint("Initializing Flame Engine for Mode: $gameMode");
    
    if (gameMode == 'Race') {
      _initializeRaceTrack();
    } else if (gameMode == 'Parking') {
      _initializeParkingArena();
    }
  }

  void _initializeRaceTrack() {
    debugPrint("Loading 8-bit asphalt sprites...");
  }

  void _initializeParkingArena() {
    debugPrint("Loading structured obstacle layout matrix...");
  }

  // లాప్‌టాప్ కీబోర్డ్ బటన్స్ (Arrow keys & WASD) సపోర్ట్
  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final isKeyDown = event is KeyDownEvent || event is KeyRepeatEvent;

    if (isKeyDown) {
      if (keysPressed.contains(LogicalKeyboardKey.arrowUp) || keysPressed.contains(LogicalKeyboardKey.keyW)) {
        moveUp();
      }
      if (keysPressed.contains(LogicalKeyboardKey.arrowDown) || keysPressed.contains(LogicalKeyboardKey.keyS)) {
        moveDown();
      }
      if (keysPressed.contains(LogicalKeyboardKey.arrowLeft) || keysPressed.contains(LogicalKeyboardKey.keyA)) {
        moveLeft();
      }
      if (keysPressed.contains(LogicalKeyboardKey.arrowRight) || keysPressed.contains(LogicalKeyboardKey.keyD)) {
        moveRight();
      }
    }
    return KeyEventResult.handled;
  }

  // కార్ మూవ్‌మెంట్ యాక్షన్స్ (ఇవి టచ్ కీప్యాడ్ మరియు లాప్‌టాప్ కీబోర్డ్ రెండింటికీ వర్తిస్తాయి)
  void moveUp() => debugPrint("Action: Move Up (Accelerate)");
  void moveDown() => debugPrint("Action: Move Down (Brake/Reverse)");
  void moveLeft() => debugPrint("Action: Move Left");
  void moveRight() => debugPrint("Action: Move Right");
}
