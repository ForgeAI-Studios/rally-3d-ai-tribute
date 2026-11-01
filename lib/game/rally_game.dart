import 'dart:math'; 
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'player_car.dart';
import 'obstacle.dart'; 

class RallyGame extends FlameGame with KeyboardEvents, HasCollisionDetection {
  final String gameMode;
  bool useVirtualKeypad = false; 
  bool isGameOver = false; 
  late PlayerCar playerCar;

  // Scoring Parameters
  double score = 0.0;
  int highScore = 0;

  // Tracking Mechanics & Core Motion Speeds
  double roadOffset = 0.0;
  final double roadSpeed = 350.0; 
  double obstacleTimer = 0.0;
  final double spawnInterval = 1.3; 

  // Procedural Curve Vectors
  double trackCurve = 0.0;          // Current target curve displacement
  double currentCurveOffset = 0.0;   // Dynamic horizontal layout transform skew
  double curveDurationTimer = 0.0;
  final Random _random = Random();

  RallyGame({required this.gameMode});

  @override
  Future<void> onLoad() async {
    super.onLoad();
    debugPrint("Initializing Flame Engine for Mode: $gameMode");
    _loadHighScore();

    playerCar = PlayerCar()
      ..position = Vector2(size.x / 2, size.y - 150)
      ..anchor = Anchor.center;
    
    add(playerCar);
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    highScore = prefs.getInt('rally_highscore_${gameMode.toLowerCase()}') ?? 0;
  }

  Future<void> _updateHighScore() async {
    if (score.toInt() > highScore) {
      highScore = score.toInt();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('rally_highscore_${gameMode.toLowerCase()}', highScore);
    }
  }

  @override
  void render(Canvas canvas) {
    // 1. Render Terrain Base Layer
    canvas.drawRect(size.toRect(), Paint()..color = const Color(0xFF1E5E2F));

    final double roadWidth = size.x * 0.72; 
    double segmentHeight = 20.0;

    // 2. Procedurally Rasterize the Segment Matrices to Draw Curves
    for (double y = 0; y < size.y; y += segmentHeight) {
      // Apply a progressive quadratic curve skew relative to the horizon
      double perspectiveScale = (size.y - y) / size.y;
      double curveCorrection = MathUtils.pow(perspectiveScale, 2) * currentCurveOffset * 120;
      
      double roadLeft = ((size.x - roadWidth) / 2) + curveCorrection;
      final rectSegment = Rect.fromLTWH(roadLeft, y, roadWidth, segmentHeight);
      
      // Secondary stripe patterns to highlight physical velocity speeds
      bool isStripeActive = (((y + roadOffset) ~/ segmentHeight) % 2 == 0);
      canvas.drawRect(rectSegment, Paint()..color = isStripeActive ? const Color(0xFF383838) : const Color(0xFF3D3D3D));

      // Side Curbs (Red and White Legacy Warning Bands)
      final curbPaint = isStripeActive ? (Paint()..color = Colors.white) : (Paint()..color = Colors.red.shade700);
      canvas.drawRect(Rect.fromLTWH(roadLeft - 10, y, 10, segmentHeight), curbPaint);
      canvas.drawRect(Rect.fromLTWH(roadLeft + roadWidth, y, 10, segmentHeight), curbPaint);

      // Center Lane Divider Segment Dots
      if (isStripeActive && y > 80) {
        canvas.drawRect(Rect.fromLTWH(roadLeft + (roadWidth / 2) - 3, y, 6, segmentHeight), Paint()..color = Colors.white60);
      }
    }

    super.render(canvas);
  }

  @override
  void update(double dt) {
    if (isGameOver) return;

    super.update(dt);
    
    if (gameMode == 'Race') {
      roadOffset += roadSpeed * dt;
      score += 18 * dt; 

      // Curve Simulation Calculations
      curveDurationTimer += dt;
      if (curveDurationTimer > 3.0) { // Alter track directions every 3 seconds
        curveDurationTimer = 0.0;
        // Randomly alternate between straight tracks (-0.2 to 0.2), sharp lefts, or rights
        trackCurve = (_random.nextDouble() * 2.0) - 1.0; 
      }

      // Smooth out interpolation frame shifts to avoid sudden visual clipping bugs
      currentCurveOffset += (trackCurve - currentCurveOffset) * 2 * dt;

      // Obstacle Generation Mechanics
      obstacleTimer += dt;
      if (obstacleTimer >= spawnInterval) {
        obstacleTimer = 0.0;
        double roadWidth = size.x * 0.72;
        double roadLeft = (size.x - roadWidth) / 2;
        // Shift oncoming spawns closer to the skewed horizon focal points
        double targetHorizonX = roadLeft + (roadWidth / 2) + (currentCurveOffset * 120);
        double spawnX = targetHorizonX + (_random.nextDouble() * 100 - 50);
        
        // Ensure boundaries are clamped securely inside playable parameters
        spawnX = spawnX.clamp(roadLeft + 25, roadLeft + roadWidth - 55);
        add(Obstacle(position: Vector2(spawnX, -40)));
      }
    }

    // Process collisions and manage element cycles
    children.whereType<Obstacle>().forEach((obstacle) {
      if (obstacle.position.y > size.y) {
        obstacle.removeFromParent();
      }

      if (playerCar.toRect().overlaps(obstacle.toRect())) {
        isGameOver = true;
        _updateHighScore();
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
    if (playerCar.position.y > 140) playerCar.position.y -= 15;
  }
  void moveDown() {
    if (isGameOver) return;
    if (playerCar.position.y < size.y - 120) playerCar.position.y += 15;
  }
  void moveLeft() {
    if (isGameOver) return;
    if (playerCar.position.x > (size.x * 0.12)) playerCar.position.x -= 18;
  }
  void moveRight() {
    if (isGameOver) return;
    if (playerCar.position.x < (size.x * 0.88)) playerCar.position.x += 18;
  }

  void resetGame() {
    isGameOver = false;
    score = 0.0;
    roadOffset = 0.0;
    obstacleTimer = 0.0;
    trackCurve = 0.0;
    currentCurveOffset = 0.0;
    _loadHighScore();
    
    children.whereType<Obstacle>().forEach((obstacle) {
      obstacle.removeFromParent();
    });
    
    playerCar.position = Vector2(size.x / 2, size.y - 150);
    debugPrint("Game Reset completed successfully!");
  }
}

// Inline helper utility to handle backward compatible power calculations securely
class MathUtils {
  static double pow(double base, int exponent) {
    double result = 1.0;
    for (int i = 0; i < exponent; i++) {
      result *= base;
    }
    return result;
  }
}
