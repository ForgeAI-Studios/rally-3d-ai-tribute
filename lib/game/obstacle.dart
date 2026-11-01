import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Obstacle extends PositionComponent {
  final double speed = 300.0;

  Obstacle({required Vector2 position}) : super(position: position, size: Vector2(30, 40));

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Render an authentic retro orange traffic cone shape using canvas vectors
    final paint = Paint()..color = Colors.orangeAccent;
    final path = Path();
    
    // Draw triangle cone base mesh outline vectors
    path.moveTo(size.x / 2, 0); // Apex top tip
    path.lineTo(0, size.y);     // Bottom Left base point
    path.lineTo(size.x, size.y); // Bottom Right base point
    path.close();
    
    canvas.drawPath(path, paint);

    // Draw the white visibility strip over the orange cone frame
    final stripPaint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(size.x * 0.25, size.y * 0.4, size.x * 0.5, 8), stripPaint);
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Obstacles move programmatically downward to create the passing-by driving illusion
    position.y += speed * dt;
  }
}
