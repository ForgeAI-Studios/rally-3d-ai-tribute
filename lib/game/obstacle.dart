import 'package:flame/components.dart';
import 'package:flame/collisions.dart'; // కొలిజన్ కోసం యాడ్ చేసాం
import 'package:flutter/material.dart';

// HasHierarchySnippets లేదా CollisionCallbacks యాడ్ చేస్తున్నాం
class Obstacle extends PositionComponent with CollisionCallbacks {
  final double speed = 300.0;

  Obstacle({required Vector2 position}) : super(position: position, size: Vector2(30, 40));

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // అడ్డంకి చుట్టూ ఒక వర్చువల్ హిట్ బాక్స్ యాడ్ చేస్తున్నాం
    add(RectangleHitbox());
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()..color = Colors.orangeAccent;
    final path = Path();
    
    path.moveTo(size.x / 2, 0); 
    path.lineTo(0, size.y);     
    path.lineTo(size.x, size.y); 
    path.close();
    
    canvas.drawPath(path, paint);

    final stripPaint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(size.x * 0.25, size.y * 0.4, size.x * 0.5, 8), stripPaint);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += speed * dt;
  }
}
