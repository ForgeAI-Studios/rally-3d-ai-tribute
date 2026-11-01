import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class PlayerCar extends PositionComponent {
  // కార్ మూవ్‌మెంట్ స్పీడ్ కాన్స్టెంట్
  final double speed = 250.0;
  Vector2 velocity = Vector2.zero();

  PlayerCar() : super(size: Vector2(40, 70)); // కారు వెడల్పు 40, పొడవు 70

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // ఇమేజ్ లేకపోయినా పాత Nokia వైబ్ ఇచ్చేలా ఒక రెడ్ కలర్ కారుని డ్రా చేస్తున్నాం
    final paint = Paint()..color = Colors.redAccent;
    
    // కార్ మెయిన్ బాడీ
    canvas.drawRRect(
      RRect.fromRectAndRadius(size.toRect(), const Radius.circular(8)),
      paint,
    );

    // కార్ విండ్‌షీల్డ్ (అద్దం) - బ్లాక్ కలర్
    final glassPaint = Paint()..color = Colors.black;
    canvas.drawRect(
      Rect.fromLTWH(5, 15, size.x - 10, 15),
      glassPaint,
    );

    // కార్ వీల్స్ (చక్రాలు) - గోల్డెన్/ఎల్లో కలర్
    final wheelPaint = Paint()..color = Colors.amber;
    canvas.drawRect(const Rect.fromLTWH(-5, 10, 5, 15), wheelPaint); // ఫ్రంట్ లెఫ్ట్
    canvas.drawRect(Rect.fromLTWH(size.x, 10, 5, 15), wheelPaint);  // fఫ్రంట్ రైట్
    canvas.drawRect(const Rect.fromLTWH(-5, 45, 5, 15), wheelPaint); // బాక్ లెఫ్ట్
    canvas.drawRect(Rect.fromLTWH(size.x, 45, 5, 15), wheelPaint);  // బాక్ రైట్
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // కారు పొజిషన్‌ను నిరంతరం అప్‌డేట్ చేయడం
    position += velocity * dt;
    
    // ప్రతి యాక్షన్ తర్వాత స్పీడ్‌ను నెమ్మదిగా సున్నా చేయడం (Friction effect)
    velocity.setZero();
  }

  // ఈ ఫంక్షన్లు మెయిన్ గేమ్ ఇంజిన్ నుండి కాల్ అవుతాయి
  void moveLeft() => velocity.x = -speed;
  void moveRight() => velocity.x = speed;
  void moveUp() => velocity.y = -speed;
  void moveDown() => velocity.y = speed;
}
