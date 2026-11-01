import 'dart:math'; 
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart'; // local storage కోసం
import 'player_car.dart';
import 'obstacle.dart'; 

class RallyGame extends FlameGame with KeyboardEvents, HasCollisionDetection {
  final String gameMode;
  bool useVirtualKeypad = false; 
  bool isGameOver = false; 
  late PlayerCar playerCar;

  // Scoring Variables
  double score = 0.0;
  int highScore = 0;

  // Environment Engine Variables
  double roadOffset = 0.0;
  final double roadSpeed = 300.0; 
  double obstacleTimer = 0.0;
  final double spawnInterval = 1.5; 

  RallyGame({required this.gameMode});

  @override
  Future<void> onLoad() async {
    super.onLoad();
    debugPrint("Initializing Flame Engine for Mode: $gameMode");
    
    // Load local high score data immediately upon game entry
    _loadHighScore();

    playerCar = PlayerCar()
      ..position = Vector2(size.x / 2, size.y - 150)
      ..anchor = Anchor.center;
    
    add(playerCar);
  }

  // Local storage management routines
  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    highScore = prefs.getInt('rally_highscore_${gameMode.toLowerCase()}') ?? 0;
  }

  Future<void> _updateHighScore() async {
    if (score.toInt() > highScore) {
      highScore = score.toInt();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('rally_highscore_${gameMode.toLowerCase()}', highScore);
      debugPrint("New High Score saved: $highScore");
    }
  }

  @override
  void render(Canvas canvas) {
    // 1. Background Grass Environment Canvas
    canvas.drawRect(size.toRect(), Paint()..color = const Color(0xFF2E7D32));

    // 2. Center Grey Asphalt Track Strip Lines
    final double roadWidth = size.x * 0.7; 
    final double roadLeft = (size.x - roadWidth) / 2;
    final rectRoad = Rect.fromLTWH(roadLeft, 0, roadWidth, size.y);
    canvas.drawRect(rectRoad, Paint()..color = const Color(0xFF424242));

    // 3. Safety Curbs Layout Borders (Red & White Bands)
    final paintWhite = Paint()..color = Colors.white;
    final paintRed = Paint()..color = Colors.red;
    
    double segmentHeight = 40.0;
    for (double y = -segmentHeight; y < size.y + segmentHeight; y += segmentHeight) {
      double currentY = y + (roadOffset % segmentHeight);
      final borderPaint = ((y ~/ segmentHeight) % 2 == 0) ? paintWhite : paintRed;
      
      canvas.drawRect(Rect.fromLTWH(roadLeft - 8, currentY, 8, segmentHeight), borderPaint);
      canvas.drawRect(Rect.fromLTWH(roadLeft + roadWidth, currentY, 8, segmentHeight), borderPaint);
    }

    // 4. Center Dashed Lane Separators
    final paintDivider = Paint()..color = Colors.white.withOpacity(0.6);
    double dashHeight = 30.0;
    double dashGap = 30.0;
    for (double y = -dashHeight; y < size.y + dashHeight; y += (dashHeight + dashGap)) {
      double currentY = y + (roadOffset % (dashHeight + dashGap));
      canvas.drawRect(Rect.fromLTWH(size.x / 2 - 3, currentY, 6, dashHeight), paintDivider);
    }

    super.render(canvas);
  }

  @override
  void update(double dt) {
    if (isGameOver) return;

    super.update(dt);
    
    if (gameMode == 'Race') {
      roadOffset += roadSpeed * dt;
      
      // Programmatically increment score metrics based on survival frames
      score += 15 * dt; 

      // Obstacle spawning sequence clock ticks
      obstacleTimer += dt;
      if (obstacleTimer >= spawnInterval) {
        obstacleTimer = 0.0;
        double roadWidth = size.x * 0.7;
        double roadLeft = (size.x - roadWidth) / 2;
        double randomX = roadLeft + 20 + Random().nextDouble() * (roadWidth - 70);
        add(Obstacle(position: Vector2(randomX, -50)));
      }
    }

    // Process active elements out of bounds and evaluate collision overlays
    children.whereType<Obstacle>().forEach((obstacle) {
      if (obstacle.position.y > size.y) {
        obstacle.removeFromParent();
      }

      if (playerCar.toRect().overlaps(obstacle.toRect())) {
        isGameOver = true;
        _updateHighScore(); // Check and commit high score changes upon impact
        debugPrint("CRASH!!! GAME OVER!");
      }
    });
  }

  // Engine control invocation routing lines
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

  // Complete game environment state variables reset sequence
  void resetGame() {
    isGameOver = false;
    score = 0.0;
    roadOffset = 0.0;
    obstacleTimer = 0.0;
    _loadHighScore();
    
    children.whereType<Obstacle>().forEach((obstacle) {
      obstacle.removeFromParent();
    });
    
    playerCar.position = Vector2(size.x / 2, size.y - 150);
    debugPrint("Game Reset completed successfully!");
  }
}
