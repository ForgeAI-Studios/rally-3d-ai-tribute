import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'rally_game.dart';

// Changed parent type from PositionComponent to SpriteComponent to track untracked textures
class Obstacle extends SpriteComponent with HasGameRef<RallyGame>, CollisionCallbacks {
  final double speed = 300.0;

  Obstacle({required Vector2 position}) : super(position: position, size: Vector2(30, 40));

  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // Programmatically streams and binds your local asset file to this visual frame
    sprite = await gameRef.loadSprite('cone_obstacle.png');
    
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += speed * dt;
  }
}
