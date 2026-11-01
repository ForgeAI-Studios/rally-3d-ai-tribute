import 'dart:math'; // రాండమ్ పొజిషన్ల కోసం యాడ్ చేసాం
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'player_car.dart';
import 'obstacle.dart'; // అడ్డంకుల క్లాస్‌ను ఇంపోర్ట్ చేసాం

class RallyGame extends FlameGame with KeyboardEvents {
  final String gameMode;
  bool useVirtualKeypad = false; 
  late PlayerCar playerCar;

  // రోడ్డు కదలిక కోసం వేరియబుల్స్
  double roadOffset = 0.0;
  final double roadSpeed = 300.0; // రోడ్డు కదిలే వేగం

  // అడ్డంకులు (Obstacles) స్పాన్ చేయడానికి వేరియబుల్స్
  double obstacleTimer = 0.0;
  final double spawnInterval = 1.5; // ప్రతి 1.5 సెకన్లకు ఒక ట్రాఫిక్ కోన్ వస్తుంది

  RallyGame({required this.gameMode});

  @override
  Future<void> onLoad() async {
    super.onLoad();
    debugPrint("Initializing Flame Engine for Mode: $gameMode");
    
    playerCar = PlayerCar()
      ..position = Vector2(size.x / 2, size.y - 150)
      ..anchor = Anchor.center;
    
    add(playerCar);
  }

  @override
  void render(Canvas canvas) {
    // 1. పచ్చటి గడ్డి (Background Environment)
    canvas.drawRect(size.toRect(), Paint()..color = const Color(0xFF2E7D32));

    // 2. మెయిన్ తారు రోడ్డు (Center Grey Track)
    final double roadWidth = size.x * 0.7; // స్క్రీన్ వెడల్పులో 70% రోడ్డు
    final double roadLeft = (size.x - roadWidth) / 2;
    final rectRoad = Rect.fromLTWH(roadLeft, 0, roadWidth, size.y);
    canvas.drawRect(rectRoad, Paint()..color = const Color(0xFF424242));

    // 3. రోడ్డు పక్కన ఉండే సేఫ్టీ లైన్స్ (Red & White Borders)
    final paintWhite = Paint()..color = Colors.white;
    final paintRed = Paint()..color = Colors.red;
    
    double segmentHeight = 40.0;
    for (double y = -segmentHeight; y < size.y + segmentHeight; y += segmentHeight) {
      double currentY = y + (roadOffset % segmentHeight);
      final borderPaint = ((y ~/ segmentHeight) % 2 == 0) ? paintWhite : paintRed;
      
      // లెఫ్ట్ బోర్డర్ మరియు రైట్ బోర్డర్ లైన్స్
      canvas.drawRect(Rect.fromLTWH(roadLeft - 8, currentY, 8, segmentHeight), borderPaint);
      canvas.drawRect(Rect.fromLTWH(roadLeft + roadWidth, currentY, 8, segmentHeight), borderPaint);
    }

    // 4. రోడ్డు మధ్యలో ఉండే డివైడర్ డాష్ లైన్స్ (White Strips)
    final paintDivider = Paint()..color = Colors.white.withOpacity(0.6);
    double dashHeight = 30.0;
    double dashGap = 30.0;
    for (double y = -dashHeight; y < size.y + dashHeight; y += (dashHeight + dashGap)) {
      double currentY = y + (roadOffset % (dashHeight + dashGap));
      canvas.drawRect(Rect.fromLTWH(size.x / 2 - 3, currentY, 6, dashHeight), paintDivider);
    }

    // మిగిలిన గేమ్ ఎలిమెంట్స్ (కార్) రెండర్ అవ్వడానికి super కాల్ చేయాలి
    super.render(canvas);
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // రేస్ మోడ్‌లో ఉంటే రోడ్డు వెనక్కి కదులుతూ ఉంటుంది (కార్ ముందుకు వెళ్తున్న ఫీలింగ్ వస్తుంది)
    if (gameMode == 'Race') {
      roadOffset += roadSpeed * dt;

      // ప్రతి 1.5 సెకన్లకు రోడ్డుపై రాండమ్ పొజిషన్ లో ఒక కొత్త కోన్ యాడ్ చేయడం
      obstacleTimer += dt;
      if (obstacleTimer >= spawnInterval) {
        obstacleTimer = 0.0;
        
        double roadWidth = size.x * 0.7;
        double roadLeft = (size.x - roadWidth) / 2;
        
        // రోడ్డు సరిహద్దుల లోపలే అడ్డంకులు వచ్చేలా లెక్కించడం
        double randomX = roadLeft + 20 + Random().nextDouble() * (roadWidth - 70);
        
        // స్క్రీన్ పైభాగాన (-50 వై లొకేషన్ లో) కోన్ క్రియేట్ చేసి యాడ్ చేస్తున్నాం
        add(Obstacle(position: Vector2(randomX, -50)));
      }
    }

    // స్క్రీన్ దాటి కిందకు వెళ్ళిపోయిన పాత అడ్డంకులను మెమొరీ నుండి డిలీట్ చేయడం
    children.whereType<Obstacle>().forEach((obstacle) {
      if (obstacle.position.y > size.y) {
        obstacle.removeFromParent();
      }
    });
  }

  @override
  void handleSwipe(Offset delta) {
    if (useVirtualKeypad) return;
    if (delta.dx < -5) moveLeft();
    if (delta.dx > 5) moveRight();
    if (delta.dy < -5) moveUp();
    if (delta.dy > 5) moveDown();
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      if (keysPressed.contains(LogicalKeyboardKey.arrowUp) || keysPressed.contains(LogicalKeyboardKey.keyW)) moveUp();
      if (keysPressed.contains(LogicalKeyboardKey.arrowDown) || keysPressed.contains(LogicalKeyboardKey.keyS)) moveDown();
      if (keysPressed.contains(LogicalKeyboardKey.arrowLeft) || keysPressed.contains(LogicalKeyboardKey.keyA)) moveLeft();
      if (keysPressed.contains(LogicalKeyboardKey.arrowRight) || keysPressed.contains(LogicalKeyboardKey.keyD)) moveRight();
    }
    return KeyEventResult.handled;
  }

  void moveUp() {
    if (playerCar.position.y > 100) playerCar.moveUp();
  }
  void moveDown() {
    if (playerCar.position.y < size.y - 100) playerCar.moveDown();
  }
  void moveLeft() {
    if (playerCar.position.x > (size.x * 0.15) + 30) playerCar.moveLeft();
  }
  void moveRight() {
    if (playerCar.position.x < (size.x * 0.85) - 30) playerCar.moveRight();
  }
}
