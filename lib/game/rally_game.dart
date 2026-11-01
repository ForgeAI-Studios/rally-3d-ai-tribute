import 'package:flame/game.dart';
import 'package:flame/components.dart'; // కరెక్ట్ ఇంపోర్ట్ యాడ్ చేసాం
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'player_car.dart';

class RallyGame extends FlameGame with KeyboardEvents {
  final String gameMode;
  bool useVirtualKeypad = false; 
  late PlayerCar playerCar;

  RallyGame({required this.gameMode});

  @override
  Future<void> onLoad() async {
    super.onLoad();
    debugPrint("Initializing Flame Engine for Mode: $gameMode");
    
    playerCar = PlayerCar()
      ..position = Vector2(size.x / 2, size.y - 150)
      ..anchor = Anchor.center;
    
    add(playerCar);

    if (gameMode == 'Race') {
      _initializeRaceTrack();
    } else if (gameMode == 'Parking') {
      _initializeParkingArena();
    }
  }

  void _initializeRaceTrack() => debugPrint("Loading Race Track Vector Maps...");
  void _initializeParkingArena() => debugPrint("Loading Parking Matrix...");

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
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

  void moveUp() => playerCar.moveUp();
  void moveDown() => playerCar.moveDown();
  void moveLeft() => playerCar.moveLeft();
  void moveRight() => playerCar.moveRight();
}
