import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';
import 'package:one_pixel_game_app/constants/animation_configs.dart';
import 'package:one_pixel_game_app/constants/globals.dart';
import 'package:one_pixel_game_app/games/one_pixel_game.dart';
import 'package:one_pixel_game_app/objects/platform.dart';

enum LuffyCharacterAnimationState {
  idle,
  walk,
  jump,
}

class LuffyCharacter extends SpriteAnimationGroupComponent<LuffyCharacterAnimationState>
    with CollisionCallbacks, KeyboardHandler, HasGameRef<OnePixelGame> {
  final double _gravity = 15;
  final Vector2 velocity = Vector2.zero();
  final double _jumpSpeed = 400;

  final Vector2 _up = Vector2(0, -1);

  static const double _minMoveSpeed = 125;
  static const double _maxMoveSpeed = _minMoveSpeed + 100;

  bool isFacingRight = true;

  double _currentMoveSpeed = _minMoveSpeed;

  bool _jumpInput = false;
  bool isOnGround = false;

  int _hAxisInput = 0;

  late Vector2 _minClamp;
  late Vector2 _maxClamp;

  bool _pause = false;

  LuffyCharacter({
    required Vector2 position,
    required Rectangle levelBounds,
  }) : super(
          position: position,
          size: Vector2(
            Globals.tileSize * 4,
            Globals.tileSize * 4,
          ),
          anchor: Anchor.center,
        ) {
    debugMode = false;
    // Prevent Character from going out of bounds of level.
    // Since anchor is in the center, split size in half for calculation.
    _minClamp = levelBounds.topLeft + (size / 2);
    _maxClamp = levelBounds.bottomRight + (size / 2);

    add(CircleHitbox());
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final SpriteAnimation idle = await AnimationConfigs.luffyCharacter.idle();
    final SpriteAnimation walking = await AnimationConfigs.luffyCharacter.walking();
    final SpriteAnimation jumping = await AnimationConfigs.luffyCharacter.jumping();

    animations = {
      LuffyCharacterAnimationState.idle: idle,
      LuffyCharacterAnimationState.walk: walking,
      LuffyCharacterAnimationState.jump: jumping,
    };

    current = LuffyCharacterAnimationState.idle;
  }

  void velocityUpdate() {
    velocity.x = _hAxisInput * _currentMoveSpeed;
    // Modify Character's velocity based on inputs and gravity.
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_jumpSpeed, 150);
  }

  void positionUpdate(double dt) {
    // Distance = velocity * time.
    Vector2 distance = velocity * dt;
    position += distance;

    // Screen boundaries for Character, top left and bottom right points.
    position.clamp(_minClamp, _maxClamp);
    // if (_hAxisInput != 0 && isOnGround) {
    // FlameAudio.play(Globals.luffyRunningSandalsSFX, volume: 0.3);
    // }
  }

  bool isPlayingSound = false;
  // Stagger his speed while idle until he runs consistently.
  void speedUpdate() {
    if (_hAxisInput == 0) {
      _currentMoveSpeed = _minMoveSpeed;
      // FlameAudio.bgm.stop();
    } else {
      if (_currentMoveSpeed <= _maxMoveSpeed) {
        _currentMoveSpeed++;
        // if (isPlayingSound == false) {
        //   isPlayingSound = true;
        //   FlameAudio.play(Globals.luffyRunningSandalsSFX, volume: 0.8);
        // } else {
        //   Future.delayed(const Duration(seconds: 2))
        //       .then((value) => isPlayingSound = false);
        // }
        // dartAsyc.Timer? timer;
        // timer = dartAsyc.Timer.periodic(const Duration(seconds: 1),
        //     (dartAsyc.Timer t) {
        //   // if (FlameAudio.bgm.isPlaying == false &&
        //   //     (_hAxisInput < 0 || _hAxisInput > 0)) {
        //     FlameAudio.playLongAudio(Globals.luffyRunningSandalsSFX,
        //         volume: 0.8);
        //   // }
        // });
        // timer?.cancel();

        // Future.delayed(const Duration(seconds: 1)).then(
        //   (value) {
        // if (FlameAudio.bgm.isPlaying == false) {
        //   FlameAudio.playLongAudio(Globals.luffyRunningSandalsSFX, volume: 0.8);
        // }
        //   },
        // );
        // FlameAudio.play(Globals.luffyRunningSandalsSFX, volume: 0.8); // TODO: NOW
      }
    }
  }

  // Set facing direction.
  void facingDirectionUpdate() {
    if (_hAxisInput > 0) {
      isFacingRight = true;
      // FlameAudio.bgm.play(Globals.luffyRunningSandalsSFX);
    } else {
      isFacingRight = false;
      // FlameAudio.bgm.stop();
    }

    if ((_hAxisInput < 0 && scale.x > 0) || (_hAxisInput > 0 && scale.x < 0)) {
      flipHorizontallyAroundCenter();
      // if (isPlayingSound == false) {
      //   isPlayingSound = true;
      //   FlameAudio.play(Globals.luffyRunningSandalsSFX, volume: 0.8);
      // } else {
      //   Future.delayed(const Duration(seconds: 2))
      //       .then((value) => isPlayingSound = false);
      // }
    }
  }

  // Allow jump only if jump button pressed and player is on the ground.
  void jumpUpdate() {
    if (_jumpInput && isOnGround) {
      jump();
    }
  }

  void jump() {
    velocity.y = -_jumpSpeed;
    isOnGround = false;

    // Play jump sound.
    FlameAudio.play(Globals.luffyJumpSFX, volume: 0.3);
  }

  void luffyCharacterAnimationUpdate() {
    if (!isOnGround) {
      current = LuffyCharacterAnimationState.jump;
    } else if (_hAxisInput < 0 || _hAxisInput > 0) {
      current = LuffyCharacterAnimationState.walk;
    } else if (_hAxisInput == 0) {
      current = LuffyCharacterAnimationState.idle;
    }
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _hAxisInput = 0;

    _hAxisInput += keysPressed.contains(LogicalKeyboardKey.arrowLeft) ? -1 : 0;
    _hAxisInput += keysPressed.contains(LogicalKeyboardKey.arrowRight) ? 1 : 0;
    _jumpInput = keysPressed.contains(LogicalKeyboardKey.space);

    if (keysPressed.contains(LogicalKeyboardKey.keyA)) {
      _pauseGame();
    }

    return true;
  }

  void _pauseGame() {
    FlameAudio.play(Globals.pauseSFX);

    !_pause ? gameRef.pauseEngine() : gameRef.resumeEngine();

    _pause = !_pause;
  }

  @override
  void update(double dt) {
    super.update(dt);
    /*  dt effects velocity, so this makes sure Character doesn't 
        go too far when there's a lag in the framerate. 

        Average dt is 0.016668.
      */
    if (dt > 0.05) return;

    jumpUpdate();
    velocityUpdate();
    positionUpdate(dt);
    speedUpdate();
    facingDirectionUpdate();
    luffyCharacterAnimationUpdate();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is Platform) {
      if (intersectionPoints.length == 2) {
        platformPositionCheck(intersectionPoints);
      }
    }
  }

  // Move Character out of the platform he's standing on.
  void platformPositionCheck(Set<Vector2> intersectionPoints) {
    // Calculate the collision normal and penetration depth
    final Vector2 mid =
        (intersectionPoints.elementAt(0) + intersectionPoints.elementAt(1)) / 2;

    final Vector2 collisionNormal = absoluteCenter - mid;
    double penetrationDepth = (size.x / 2) - collisionNormal.length;
    collisionNormal.normalize();

    // If collision normal is almost upwards, player is on the ground.
    if (_up.dot(collisionNormal) > 0.9) {
      isOnGround = true;
    }

    // Fix this collision by moving the player along the collision normal by penetrationDepth.
    position += collisionNormal.scaled(penetrationDepth);
  }
}
