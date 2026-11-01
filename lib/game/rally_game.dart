import 'dart:math'; 
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'player_car.dart';
import 'obstacle.dart'; 

class RallyGame extends FlameGame with KeyboardEvents, HasCollisionDetection {
  final String gameMode;
  bool useVirtualKeypad = false; 
  bool isGameOver = false; 
  late PlayerCar playerCar;

  // రోడ్డు కదలిక కోసం వేరియబుల్స్
  double roadOffset = 0.0;
  final double roadSpeed = 300.0; 

  // అడ్డంకులు (Obstacles) స్పాన్ చేయడానికి వేరియబుల్స్
  double obstacleTimer = 0.0;
  final double spawnInterval = 1.5; 

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
    final double roadWidth = size.x * 0.7; 
    final double roadLeft = (size.x - roadWidth) / 2;
    final rectRoad = Rect.fromLTWH(roadLeft, 0, roadWidth, size.y);
    canvas.drawRect(rectRoad, Paint()..color = const Color(0xFF424242));

    // 3. రోడ్డు పక్కన ఉండే సేфటీ లైన్స్ (Red & White Borders)
    final paintWhite = Paint()..color = Colors.white;
    final paintRed = Paint()..color = Colors.red;
    
    double segmentHeight = 40.0;
    for (double y = -segmentHeight; y < size.y + segmentHeight; y += segmentHeight) {
      double currentY = y + (roadOffset % segmentHeight);
      final borderPaint = ((y ~/ segmentHeight) % 2 == 0) ? paintWhite : paintRed;
      
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

    super.render(canvas);
  }

  // ఈ ఫంక్షన్‌ను మీ RallyGame క్లాస్ లోపల అందరికంటే కింద యాడ్ చేయండి:
void resetGame() {
  isGameOver = false;
  roadOffset = 0.0;
  obstacleTimer = 0.0;
  
  // రోడ్డుపై ఉన్న పాత అడ్డంకులన్నింటినీ క్లియర్ చేయడం
  children.whereType<Obstacle>().forEach((obstacle) {
    obstacle.removeFromParent();
  });
  
  // కారును మళ్లీ పాత పొజిషన్ కి తీసుకురావడం
  playerCar.position = Vector2(size.x / 2, size.y - 150);
  debugPrint("Game Reset completed successfully!");
}


  @override
  void update(double dt) {
    if (isGameOver) return;

    super.update(dt);
    
    if (gameMode == 'Race') {
      roadOffset += roadSpeed * dt;

      obstacleTimer += dt;
      if (obstacleTimer >= spawnInterval) {
        obstacleTimer = 0.0;
        
        double roadWidth = size.x * 0.7;
        double roadLeft = (size.x - roadWidth) / 2;
        
        double randomX = roadLeft + 20 + Random().nextDouble() * (roadWidth - 70);
        add(Obstacle(position: Vector2(randomX, -50)));
      }
    }

    // మెమొరీ క్లీనప్ మరియు పక్కా రెక్టాంగిల్ బౌండరీ కొలిజన్ డిటెక్షన్
    children.whereType<Obstacle>().forEach((obstacle) {
      if (obstacle.position.y > size.y) {
        obstacle.removeFromParent();
      }

      // కారు బాక్స్ మరియు కోన్ బాక్స్ ఒకదానికొకటి ఓవర్లాప్ అయ్యాయో లేదో చెక్ చేయడం
      if (playerCar.toRect().overlaps(obstacle.toRect())) {
        isGameOver = true;
        debugPrint("CRASH!!! GAME OVER!");
      }
    });
  }

  @override
  void handleSwipe(Offset delta) {
    if (isGameOver || useVirtualKeypad) return;
    if (delta.dx < -5) moveLeft();
    if (delta.dx > 5) moveRight();
    if (delta.dy < -5) moveUp();
    if (delta.dy > 5) moveDown();
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (isGameOver) return KeyEventResult.handled;

    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      if (keysPressed.contains(LogicalKeyboardKey.arrowUp) || keysPressed.contains(LogicalKeyboardKey.keyW)) moveUp();
      if (keysPressed.contains(LogicalKeyboardKey.arrowDown) || keysPressed.contains(LogicalKeyboardKey.keyS)) moveDown();
      if (keysPressed.contains(LogicalKeyboardKey.arrowLeft) || keysPressed.contains(LogicalKeyboardKey.keyA)) moveLeft();
      if (keysPressed.contains(LogicalKeyboardKey.arrowRight) || keysPressed.contains(LogicalKeyboardKey.keyD)) moveRight();
    }
    return KeyEventResult.handled;
  }

  void moveUp() {
    if (isGameOver) return;
    if (playerCar.position.y > 100) playerCar.moveUp();
  }
  void moveDown() {
    if (isGameOver) return;
    if (playerCar.position.y < size.y - 100) playerCar.moveDown();
  }
  void moveLeft() {
    if (isGameOver) return;
    if (playerCar.position.x > (size.x * 0.15) + 30) playerCar.moveLeft();
  }
  void moveRight() {
    if (isGameOver) return;
    if (playerCar.position.x < (size.x * 0.85) - 30) playerCar.moveRight();
  }
}
