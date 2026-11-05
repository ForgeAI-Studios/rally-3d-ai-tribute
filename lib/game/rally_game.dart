import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'obstacle.dart';
import 'parking_spot.dart';
import 'player_car.dart';

class RallyGame extends FlameGame
    with KeyboardEvents, HasCollisionDetection {
  final String gameMode;
  int level;

  bool useVirtualKeypad = false;
  bool isGameOver = false;
  bool isLevelCleared = false;

  late PlayerCar playerCar;

  double score = 0.0;
  int highScore = 0;

  double roadOffset = 0.0;
  late double roadSpeed;
  double obstacleTimer = 0.0;
  late double spawnInterval;

  double trackCurve = 0.0;
  double currentCurveOffset = 0.0;
  double curveDurationTimer = 0.0;

  final Random _random = Random();

  RallyGame({
    required this.gameMode,
    required this.level,
  });

  @override
  Future<void> onLoad() async {
    super.onLoad();

    _initializeLevelConfig();

    playerCar = PlayerCar()
      ..position = Vector2(size.x / 2, size.y - 150)
      ..anchor = Anchor.center;

    add(playerCar);
  }

  void _initializeLevelConfig() {
    debugPrint('Loading configuration for Mode: $gameMode | Level: $level');

    _loadHighScore();

    roadSpeed = 300.0 + (level * 50);
    spawnInterval = max(0.6, 1.6 - (level * 0.2));

    if (gameMode == 'Race') {
      _initializeRaceTrack();
    } else if (gameMode == 'Parking') {
      _initializeParkingArena();
    }
  }

  void _initializeRaceTrack() {
    debugPrint('Race Mode Configured.');
  }

  void _initializeParkingArena() {
    debugPrint('Generating Dynamic Parking Obstacles for Level: $level');

    final currentRoadWidth = size.x * (0.76 - (level * 0.04));
    final roadLeft = (size.x - currentRoadWidth) / 2;

    if (level == 1) {
      add(
        Obstacle(
          position: Vector2(roadLeft + 20, 240),
        ),
      );
      add(
        Obstacle(
          position: Vector2(
            roadLeft + currentRoadWidth - 50,
            240,
          ),
        ),
      );
      add(
        ParkingSpot(
          position: Vector2((size.x / 2) - 25, 100),
        ),
      );
    } else if (level == 2) {
      add(
        Obstacle(
          position: Vector2(roadLeft + 35, 260),
        ),
      );
      add(
        Obstacle(
          position: Vector2(
            roadLeft + currentRoadWidth - 65,
            260,
          ),
        ),
      );
      add(
        Obstacle(
          position: Vector2((size.x / 2) - 15, 160),
        ),
      );
      add(
        ParkingSpot(
          position: Vector2((size.x / 2) - 25, 80),
        ),
      );
    } else {
      add(
        Obstacle(
          position: Vector2(roadLeft + 45, 280),
        ),
      );
      add(
        Obstacle(
          position: Vector2(
            roadLeft + currentRoadWidth - 75,
            280,
          ),
        ),
      );
      add(
        Obstacle(
          position: Vector2((size.x / 2) - 60, 180),
        ),
      );
      add(
        Obstacle(
          position: Vector2((size.x / 2) + 30, 180),
        ),
      );
      add(
        ParkingSpot(
          position: Vector2((size.x / 2) - 25, 50),
        ),
      );
    }
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();

    highScore =
        prefs.getInt('rally_highscore_${gameMode.toLowerCase()}_$level') ?? 0;
  }

  Future<void> _updateHighScore() async {
    if (score.toInt() > highScore) {
      highScore = score.toInt();

      final prefs = await SharedPreferences.getInstance();

      await prefs.setInt(
        'rally_highscore_${gameMode.toLowerCase()}_$level',
        highScore,
      );
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      size.toRect(),
      Paint()..color = const Color(0xFF1E5E2F),
    );

    final roadWidth = size.x * (0.76 - (level * 0.04));
    const segmentHeight = 20.0;

    for (double y = 0; y < size.y; y += segmentHeight) {
      double curveCorrection = 0.0;

      if (gameMode == 'Race') {
        final perspectiveScale = (size.y - y) / size.y;

        curveCorrection =
            MathUtils.pow(perspectiveScale, 2) * currentCurveOffset * 120;
      }

      final roadLeft = ((size.x - roadWidth) / 2) + curveCorrection;

      final rectSegment = Rect.fromLTWH(
        roadLeft,
        y,
        roadWidth,
        segmentHeight,
      );

      final isStripeActive = gameMode == 'Race'
          ? (((y + roadOffset) ~/ segmentHeight) % 2 == 0)
          : ((y ~/ segmentHeight) % 2 == 0);

      canvas.drawRect(
        rectSegment,
        Paint()
          ..color = isStripeActive
              ? const Color(0xFF383838)
              : const Color(0xFF3D3D3D),
      );

      final curbPaint = isStripeActive
          ? (Paint()..color = Colors.white)
          : (Paint()..color = Colors.red.shade700);

      canvas.drawRect(
        Rect.fromLTWH(
          roadLeft - 10,
          y,
          10,
          segmentHeight,
        ),
        curbPaint,
      );

      canvas.drawRect(
        Rect.fromLTWH(
          roadLeft + roadWidth,
          y,
          10,
          segmentHeight,
        ),
        curbPaint,
      );

      if (isStripeActive && y > 80) {
        canvas.drawRect(
          Rect.fromLTWH(
            roadLeft + (roadWidth / 2) - 3,
            y,
            6,
            segmentHeight,
          ),
          Paint()..color = Colors.white60,
        );
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
      score += (10 + level * 5) * dt;

      curveDurationTimer += dt;

      if (curveDurationTimer > 3.0) {
        curveDurationTimer = 0.0;
        trackCurve =
            ((_random.nextDouble() * 2.0) - 1.0) * (0.6 + level * 0.15);
      }

      currentCurveOffset +=
          (trackCurve - currentCurveOffset) * 2 * dt;

      obstacleTimer += dt;

      if (obstacleTimer >= spawnInterval) {
        obstacleTimer = 0.0;

        final currentWidth = size.x * (0.76 - (level * 0.04));
        final roadLeft = (size.x - currentWidth) / 2;

        final targetHorizonX =
            roadLeft + (currentWidth / 2) + (currentCurveOffset * 120);

        var spawnX =
            targetHorizonX + (_random.nextDouble() * 100 - 50);

        spawnX = spawnX
            .clamp(
              roadLeft + 25,
              roadLeft + currentWidth - 55,
            )
            .toDouble();

        add(
          Obstacle(
            position: Vector2(spawnX, -40),
          ),
        );
      }
    }

    children.whereType<Obstacle>().forEach((obstacle) {
      if (obstacle.position.y > size.y && gameMode == 'Race') {
        obstacle.removeFromParent();
      }

      if (playerCar.toRect().overlaps(obstacle.toRect())) {
        isGameOver = true;
        _updateHighScore();
        debugPrint('CRASH!!! GAME OVER!');
      }
    });

    if (gameMode == 'Parking') {
      children.whereType<ParkingSpot>().forEach((spot) {
        if (playerCar.toRect().overlaps(spot.toRect())) {
          isLevelCleared = true;
          debugPrint('SUCCESS!!! LEVEL CLEARED!');
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
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (isGameOver || isLevelCleared) {
      return KeyEventResult.handled;
    }

    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      if (keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
          keysPressed.contains(LogicalKeyboardKey.keyW)) {
        moveUp();
      }

      if (keysPressed.contains(LogicalKeyboardKey.arrowDown) ||
          keysPressed.contains(LogicalKeyboardKey.keyS)) {
        moveDown();
      }

      if (keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
          keysPressed.contains(LogicalKeyboardKey.keyA)) {
        moveLeft();
      }

      if (keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
          keysPressed.contains(LogicalKeyboardKey.keyD)) {
        moveRight();
      }
    }

    return KeyEventResult.handled;
  }

  void moveUp() {
    if (isGameOver || isLevelCleared) return;

    if (playerCar.position.y > 60) {
      playerCar.position.y -= 15;
    }
  }

  void moveDown() {
    if (isGameOver || isLevelCleared) return;

    if (playerCar.position.y < size.y - 120) {
      playerCar.position.y += 15;
    }
  }

  void moveLeft() {
    if (isGameOver || isLevelCleared) return;

    final currentWidth = size.x * (0.76 - (level * 0.04));
    final roadLeft = (size.x - currentWidth) / 2;

    if (playerCar.position.x > roadLeft + 20) {
      playerCar.position.x -= 18;
    }
  }

  void moveRight() {
    if (isGameOver || isLevelCleared) return;

    final currentWidth = size.x * (0.76 - (level * 0.04));
    final roadLeft = (size.x - currentWidth) / 2;

    if (playerCar.position.x < roadLeft + currentWidth - 20) {
      playerCar.position.x += 18;
    }
  }

  Future<void> nextLevel() async {
    if (gameMode != 'Parking' || level >= 6) return;

    level++;
    isGameOver = false;
    isLevelCleared = false;
    score = 0.0;
    roadOffset = 0.0;
    obstacleTimer = 0.0;
    trackCurve = 0.0;
    currentCurveOffset = 0.0;

    children.whereType<Obstacle>().forEach(
      (obstacle) => obstacle.removeFromParent(),
    );

    children.whereType<ParkingSpot>().forEach(
      (spot) => spot.removeFromParent(),
    );

    await Future.delayed(const Duration(milliseconds: 15));

    _initializeLevelConfig();

    playerCar.position = Vector2(
      size.x / 2,
      size.y - 150,
    );

    debugPrint('Advanced to Level: $level successfully!');
  }

  Future<void> resetGame() async {
    isGameOver = false;
    isLevelCleared = false;
    score = 0.0;
    roadOffset = 0.0;
    obstacleTimer = 0.0;
    trackCurve = 0.0;
    currentCurveOffset = 0.0;

    children.whereType<Obstacle>().forEach(
      (obstacle) => obstacle.removeFromParent(),
    );

    children.whereType<ParkingSpot>().forEach(
      (spot) => spot.removeFromParent(),
    );

    await Future.delayed(const Duration(milliseconds: 15));

    _initializeLevelConfig();

    playerCar.position = Vector2(
      size.x / 2,
      size.y - 150,
    );

    debugPrint('Game Reset completed successfully!');
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