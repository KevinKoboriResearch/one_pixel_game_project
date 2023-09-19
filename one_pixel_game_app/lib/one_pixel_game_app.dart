import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/painting.dart';
import 'package:one_pixel_game_app/components/jump_button.dart';
import 'package:one_pixel_game_app/components/level.dart';
import 'package:one_pixel_game_app/components/player.dart';

class PixelAdventure extends FlameGame
    with
        HasKeyboardHandlerComponents,
        DragCallbacks,
        HasCollisionDetection,
        TapCallbacks {
  PixelAdventure() : super() {
    // FlameAudio.bgm.stop().then(
    //       (_) => FlameAudio.bgm.play(PixelAdventure.bgmPath, volume: 0.05),
    //     );
  }
  @override
  Color backgroundColor() => const Color(0xFF211F30);
  late CameraComponent cam;
  Player player = Player(character: 'Pink Man');
  late JoystickComponent joystick;
  bool showControls = false;
  bool playSounds = true;
  double soundVolume = 1.0;
  List<String> levelNames = [
    'Level-01',
    'Level-02',
  ];
  List<String> levelBGMs = [
    'bgm/level_1_bgm.mp3',
    'bgm/level_2_bgm.wav',
    'bgm/level_3_bgm.mp3',
    'bgm/level_4_bgm.mp3',
  ];
  int currentLevelIndex = 0;

  @override
  FutureOr<void> onLoad() async {
    // Load all images into cache
    await images.loadAllImages();

    // Load all audios into cache
    await FlameAudio.audioCache.loadAll(
      levelBGMs,
    );

    _loadLevel();

    if (showControls) {
      addJoystick();
      add(JumpButton());
    }

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (showControls) {
      updateJoystick();
    }
    super.update(dt);
  }

  void addJoystick() {
    joystick = JoystickComponent(
      priority: 10,
      knob: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/Knob.png'),
        ),
      ),
      background: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/Joystick.png'),
        ),
      ),
      margin: const EdgeInsets.only(left: 32, bottom: 32),
    );

    add(joystick);
  }

  void updateJoystick() {
    switch (joystick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.horizontalMovement = -1;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.horizontalMovement = 1;
        break;
      default:
        player.horizontalMovement = 0;
        break;
    }
  }

  Future<void> loadNextLevel() async {
    removeWhere((component) => component is Level);

    if (currentLevelIndex < levelNames.length - 1) {
      currentLevelIndex++;
      await _loadLevel();
    } else {
      // no more levels
      currentLevelIndex = 0;
      await _loadLevel();
    }
  }

  Future<void> _loadLevel() async {
    await Future.delayed(const Duration(seconds: 1), () async {
      Level world = Level(
        player: player,
        levelName: levelNames[currentLevelIndex],
      );

      cam = CameraComponent.withFixedResolution(
        world: world,
        width: 640,
        height: 360,
      );
      cam.viewfinder.anchor = Anchor.topLeft;

      addAll([cam, world]);

      if (FlameAudio.bgm.isPlaying) {
        await FlameAudio.bgm.stop();
      } else {
        // await FlameAudio.bgm.play(levelBGMs[currentLevelIndex], volume: 0.05); // TODO: ...
      }
    });
  }
}
