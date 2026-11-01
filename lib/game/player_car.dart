import 'package:flame/components.dart';
import 'package:flame/collisions.dart'; // యాడ్ చేసాం
import 'package:flutter/material.dart';

class PlayerCar extends PositionComponent with CollisionCallbacks {
  final double speed = 250.0;
  Vector2 velocity = Vector2.zero();

  PlayerCar() : super(size: Vector2(40, 70));

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // కార్ బాడీ చుట్టూ హిట్ బాక్స్ యాడ్ చేసాం
    add(RectangleHitbox());
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()..color = Colors.redAccent;
    canvas.drawRRect(
      RRect.fromRectAndRadius(size.toRect(), const Radius.circular(8)),
      paint,
    );

    final glassPaint = Paint()..color = Colors.black;
    canvas.drawRect(Rect.fromLTWH(5, 15, size.x - 10, 15), glassPaint);

    final wheelPaint = Paint()..color = Colors.amber;
    canvas.drawRect(const Rect.fromLTWH(-5, 10, 5, 15), wheelPaint); 
    canvas.drawRect(Rect.fromLTWH(size.x, 10, 5, 15), wheelPaint);  
    canvas.drawRect(const Rect.fromLTWH(-5, 45, 5, 15), wheelPaint); 
    canvas.drawRect(Rect.fromLTWH(size.x, 45, 5, 15), wheelPaint);  
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
    velocity.setZero();
  }

  void moveLeft() => velocity.x = -speed;
  void moveRight() => velocity.x = speed;
  void moveUp() => velocity.y = -speed;
  void moveDown() => velocity.y = speed;
}
