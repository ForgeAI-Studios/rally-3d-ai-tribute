import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ParkingSpot extends PositionComponent {
  ParkingSpot({required Vector2 position}) : super(position: position, size: Vector2(50, 80));

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Render a retro neon-yellow destination bounding zone layer
    final paintLine = Paint()
      ..color = Colors.yellowAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Outer border container
    canvas.drawRect(size.toRect(), paintLine);

    // Inner letter indicator 'P' vector mesh outline
    final textPaint = TextPainter(
      text: const TextSpan(
        text: 'P',
        style: TextStyle(color: Colors.yellowAccent, fontSize: 32, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    textPaint.layout();
    textPaint.paint(canvas, Offset((size.x - textPaint.width) / 2, (size.y - textPaint.height) / 2));
  }
}
