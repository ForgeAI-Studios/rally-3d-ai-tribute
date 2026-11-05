import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'rally_game.dart'; // Imports the parent game controller configurations

// Changed parent type from PositionComponent to SpriteComponent to render image profiles
class PlayerCar extends SpriteComponent with HasGameRef<RallyGame>, CollisionCallbacks {
  final double speed = 250.0;
  Vector2 velocity = Vector2.zero();

  PlayerCar() : super(size: Vector2(40, 70)); // Retains your exact placement bounds

  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // Programmatically streams and binds your local asset file to this visual frame
    sprite = await gameRef.loadSprite('retro_car.png');
    
    // Retains your trusted virtual hitbox wireframe running over the pixel asset layer
    add(RectangleHitbox());
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
