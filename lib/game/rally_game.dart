import 'dart:math'; 
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'player_car.dart';
import 'obstacle.dart'; 
import 'parking_spot.dart';

class RallyGame extends FlameGame with KeyboardEvents, HasCollisionDetection {
  final String gameMode;
  bool useVirtualKeypad = false; 
  bool isGameOver = false; 
  bool isLevelCleared = false; // Flag to track when parking arena objectives are completed successfully
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

    // Context-dependent operational sequence execution routes
    if (gameMode == 'Race') {
      _initializeRaceTrack();
    } else if (gameMode == 'Parking') {
      _initializeParkingArena();
    }
  }

  void _initializeRaceTrack() {
    debugPrint("Loading Race Track Vector Maps...");
  }

  void _initializeParkingArena() {
    debugPrint("Loading structured obstacle layout matrix...");
    
    // Add static road barriers styled after traditional parking walls using Obstacle templates
    add(Obstacle(position: Vector2((size.x / 2) - 80, 200)));
    add(Obstacle(position: Vector2((size.x / 2) + 60, 200)));
    
    // Instantiate the neon yellow destination parking bounding box overlay layer
    add(ParkingSpot(position: Vector2((size.x / 2) - 25, 80)));
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
      // Skew road lines using quadratic curves only if active mode is a high speed road race
      double curveCorrection = 0.0;
      if (gameMode == 'Race') {
        double perspectiveScale = (size.y - y) / size.y;
        curveCorrection = MathUtils.pow(perspectiveScale, 2) * currentCurveOffset * 120;
      }
      
      double roadLeft = ((size.x - roadWidth) / 2) + curveCorrection;
      final rectSegment = Rect.fromLTWH(roadLeft, y, roadWidth, segmentHeight);
      
      // Toggle speed stripe layout arrays depending on context velocity states
      bool isStripeActive = gameMode == 'Race'
          ? (((y + roadOffset) ~/ segmentHeight) % 2 == 0)
          : ((y ~/ segmentHeight) % 2 == 0);
          
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
    if (isGameOver || isLevelCleared) return;

    super.update(dt);
    
    if (gameMode == 'Race') {
      roadOffset += roadSpeed * dt;
      score += 18 * dt; 

      // Curve Simulation Calculations
      curveDurationTimer += dt;
      if (curveDurationTimer > 3.0) {
        curveDurationTimer = 0.0;
        trackCurve = (_random.nextDouble() * 2.0) - 1.0; 
      }

      currentCurveOffset += (trackCurve - currentCurveOffset) * 2 * dt;

      // Obstacle Generation Mechanics
      obstacleTimer += dt;
      if (obstacleTimer >= spawnInterval) {
        obstacleTimer = 0.0;
        double roadWidth = size.x * 0.72;
        double roadLeft = (size.x - roadWidth) / 2;
        double targetHorizonX = roadLeft + (roadWidth / 2) + (currentCurveOffset * 120);
        double spawnX = targetHorizonX + (_random.nextDouble() * 100 - 50);
        
        spawnX = spawnX.clamp(roadLeft + 25, roadLeft + roadWidth - 55);
        add(Obstacle(position: Vector2(spawnX, -40)));
      }
    }

    // Process collisions and manage element cycles
    children.whereType<Obstacle>().forEach((obstacle) {
      // Clear infinite runner elements if they cross off screen metrics during a Race
      if (obstacle.position.y > size.y && gameMode == 'Race') {
        obstacle.removeFromParent();
      }

      if (playerCar.toRect().overlaps(obstacle.toRect())) {
        isGameOver = true;
        _updateHighScore();
        debugPrint("CRASH!!! GAME OVER!");
      }
    });

    // Evaluate target overlap coordinates inside the structural Parking layout arena bounds
    if (gameMode == 'Parking') {
      children.whereType<ParkingSpot>().forEach((spot) {
        if (playerCar.toRect().overlaps(spot.toRect())) {
          isLevelCleared = true;
          debugPrint("SUCCESS!!! LEVEL CLEARED!");
        }
      });
    }
  }

  @override
  void handleSwipe(Offset delta) {
    if (isGameOver || isLevelCleared || useVirtualKeypad) return;
    if (delta.dx < -5) moveLeft();
    if (delta.dx > 5) moveRight();
    if (delta.dy < -5) moveUp();
    if (delta.dy > 5) moveDown();
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (isGameOver || isLevelCleared) return KeyEventResult.handled;

    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      if (keysPressed.contains(LogicalKeyboardKey.arrowUp) || keysPressed.contains(LogicalKeyboardKey.keyW)) moveUp();
      if (keysPressed.contains(LogicalKeyboardKey.arrowDown) || keysPressed.contains(LogicalKeyboardKey.keyS)) moveDown();
      if (keysPressed.contains(LogicalKeyboardKey.arrowLeft) || keysPressed.contains(LogicalKeyboardKey.keyA)) moveLeft();
      if (keysPressed.contains(LogicalKeyboardKey.arrowRight) || keysPressed.contains(LogicalKeyboardKey.keyD)) moveRight();
    }
    return KeyEventResult.handled;
  }

  void moveUp() {
    if (isGameOver || isLevelCleared) return;
    if (playerCar.position.y > 80) playerCar.position.y -= 15;
  }
  void moveDown() {
    if (isGameOver || isLevelCleared) return;
    if (playerCar.position.y < size.y - 120) playerCar.position.y += 15;
  }
  void moveLeft() {
    if (isGameOver || isLevelCleared) return;
    if (playerCar.position.x > (size.x * 0.12)) playerCar.position.x -= 18;
  }
  void moveRight() {
    if (isGameOver || isLevelCleared) return;
    if (playerCar.position.x < (size.x * 0.88)) playerCar.position.x += 18;
  }

  void resetGame() {
    isGameOver = false;
    isLevelCleared = false;
    score = 0.0;
    roadOffset = 0.0;
    obstacleTimer = 0.0;
    trackCurve = 0.0;
    currentCurveOffset = 0.0;
    _loadHighScore();
    
    children.whereType<Obstacle>().forEach((obstacle) {
      obstacle.removeFromParent();
    });
    
    // Clear and re-instantiate structural maps safely upon resetting parking levels
    if (gameMode == 'Parking') {
      children.whereType<ParkingSpot>().forEach((spot) {
        spot.removeFromParent();
      });
      _initializeParkingArena();
    }
    
    playerCar.position = Vector2(size.x / 2, size.y - 150);
    debugPrint("Game Reset completed successfully!");
  }
}

class MathUtils {
  static double pow(double base, int exponent) {
    double result = 1.0;
    for (int i = 0; i < exponent; i++) {
      result *= base;
    }
    return result;
  }
}
