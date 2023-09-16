import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
// import 'package:flame_audio/flame_audio.dart';
// import 'package:one_pixel_game_app/constants/globals.dart';
import 'package:one_pixel_game_app/level/level_component.dart';
import 'package:one_pixel_game_app/level/level_option.dart';

class OnePixelGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
  OnePixelGame() : super() {
    // FlameAudio.bgm.play(Globals.bgm, volume: 0.1);
  }
  late CameraComponent cameraComponent;
  final World world = World();

  LevelComponent? _currentLevel;

  @override
  Future<void> onLoad() async {
    loadLevel(LevelOption.lv_1_1);

    cameraComponent = CameraComponent(world: world)
      ..viewfinder.visibleGameSize = Vector2(450, 50)
      ..viewfinder.position = Vector2(0, 0)
      ..viewport.position = Vector2(500, 0)
      ..viewfinder.anchor = Anchor.topLeft;

    addAll([cameraComponent, world]);

    return super.onLoad();
  }

  void loadLevel(LevelOption level) {
    _currentLevel?.removeFromParent();
    _currentLevel = LevelComponent(level);
    add(_currentLevel!);
  }
}
