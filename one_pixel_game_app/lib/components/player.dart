import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';
import 'package:one_pixel_game_app/components/checkpoint.dart';
import 'package:one_pixel_game_app/components/chicken.dart';
import 'package:one_pixel_game_app/components/collision_block.dart';
import 'package:one_pixel_game_app/components/custom_hitbox.dart';
import 'package:one_pixel_game_app/components/fruit.dart';
import 'package:one_pixel_game_app/components/saw.dart';
import 'package:one_pixel_game_app/components/utils.dart';
import 'package:one_pixel_game_app/one_pixel_game_app.dart';

enum PlayerState {
  idle,
  running,
  jumping,
  falling,
  hit,
  appearing,
  disappearing
}

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, KeyboardHandler, CollisionCallbacks {
  String character;
  Player({
    super.position,
    this.character = 'Mask Dude',
  }) {
    debugMode = true;
  }

  final double stepTime = 0.05;
  // final double stepTime = 0.2;

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation jumpingAnimation;
  late final SpriteAnimation fallingAnimation;
  late final SpriteAnimation hitAnimation;
  late final SpriteAnimation appearingAnimation;
  late final SpriteAnimation disappearingAnimation;

  final double _gravity = 9.8;
  final double _jumpForce = 260;
  final double _terminalVelocity = 300;
  double horizontalMovement = 0;
  double moveSpeed = 100;
  Vector2 startingPosition = Vector2.zero();
  Vector2 velocity = Vector2.zero();
  bool isOnGround = false;
  bool hasJumped = false;
  bool gotHit = false;
  bool reachedCheckpoint = false;
  List<CollisionBlock> collisionBlocks = [];
  CustomHitbox hitbox = CustomHitbox(
    offsetX: 10,
    offsetY: 4,
    width: 14,
    height: 28,
  );
  double fixedDeltaTime = 1 / 60;
  double accumulatedTime = 0;

  @override
  FutureOr<void> onLoad() async {
    await _loadAllAnimations();
    // debugMode = true;

    startingPosition = Vector2(position.x, position.y);

    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(hitbox.width, hitbox.height),
    ));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    accumulatedTime += dt;

    while (accumulatedTime >= fixedDeltaTime) {
      if (!gotHit && !reachedCheckpoint) {
        _updatePlayerState();
        _updatePlayerMovement(fixedDeltaTime);
        _checkHorizontalCollisions();
        _applyGravity(fixedDeltaTime);
        _checkVerticalCollisions();
      }

      accumulatedTime -= fixedDeltaTime;
    }

    super.update(dt);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;
    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);

    horizontalMovement += isLeftKeyPressed ? -1 : 0;
    horizontalMovement += isRightKeyPressed ? 1 : 0;

    hasJumped = keysPressed.contains(LogicalKeyboardKey.space);

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (!reachedCheckpoint) {
      if (other is Fruit) other.collidedWithPlayer();
      if (other is Saw) _respawn();
      if (other is Chicken) other.collidedWithPlayer();
      if (other is Checkpoint) _reachedCheckpoint();
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  Future<void> _loadAllAnimations() async {
    idleAnimation = await _spriteAnimationOld('Idle', 11);
    // runningAnimation = await _spriteAnimationOld('Run', 12);
    // jumpingAnimation = await _spriteAnimationOld('Jump', 1);
    // fallingAnimation = await _spriteAnimationOld('Fall', 1);
    // hitAnimation = await _spriteAnimationOld('Hit', 7)
      // ..loop = false;
    runningAnimation = await _spriteAnimationOld('Idle', 11);
    jumpingAnimation = await _spriteAnimationOld('Idle', 11);
    fallingAnimation = await _spriteAnimationOld('Idle', 11);
    hitAnimation = await _spriteAnimationOld('Idle', 11)
      ..loop = false;
    // idleAnimation =
    //     await _spriteAnimation('idle', spritesList: [1, 2, 3, 4, 5, 6, 7]);
    // runningAnimation =
    //     await _spriteAnimation('idle', spritesList: [1, 2, 3, 4, 5, 6]);
    // jumpingAnimation =
    //     await _spriteAnimation('jumping', spritesList: [1, 2, 3, 4, 5]);
    // fallingAnimation =
    //     await _spriteAnimation('idle', spritesList: [1, 2, 3, 4, 5, 6, 7]);
    // hitAnimation =
    //     await _spriteAnimation('idle', spritesList: [1, 2, 3, 4, 5, 6, 7])
    //       ..loop = false;
    appearingAnimation = _specialSpriteAnimation('Appearing', 7);
    disappearingAnimation = _specialSpriteAnimation('Desappearing', 7);

    // List of all animations
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
      PlayerState.jumping: jumpingAnimation,
      PlayerState.falling: fallingAnimation,
      PlayerState.hit: hitAnimation,
      PlayerState.appearing: appearingAnimation,
      PlayerState.disappearing: disappearingAnimation,
    };

    // Set current animation
    current = PlayerState.idle;
  }

  Future<SpriteAnimation> _spriteAnimationOld(String state, int amount) async {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/Luffy/$state (32x32).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );
  }

  // Future<SpriteAnimation> _spriteAnimation(String state,
  //     {required List<int> spritesList}) async {
  //   return SpriteAnimation.spriteList(
  //     await Future.wait(spritesList
  //         .map((i) => Sprite.load(
  //             srcSize: Vector2.all(64),
  //             'characters/luffy/sprites/$state/luffy_${state}_sprite_$i.png'))
  //         .toList()),
  //     stepTime: stepTime,
  //     loop: true,
  //   );
  //   // game.images.fromCache('Main Characters/$character/$state (32x32).png'),
  //   // SpriteAnimationData.sequenced(
  //   //   amount: amount,
  //   //   stepTime: stepTime,
  //   //   textureSize: Vector2.all(32),
  //   // ),
  //   // );

  //   // Future<SpriteAnimation> idle() async => SpriteAnimation.spriteList(
  //   //       await Future.wait([1, 2, 4, 6]
  //   //           .map((i) =>
  //   //               Sprite.load('luffy/sprites/idle/luffy_idle_sprite_$i.png'))
  //   //           .toList()),
  //   //       stepTime: Globals.luffyIdleSpriteTime,
  //   //     );

  //   // Future<SpriteAnimation> walking() async => SpriteAnimation.spriteList(
  //   //       await Future.wait([1, 2, 3, 4, 5, 6]
  //   //           .map((i) => Sprite.load(
  //   //               'luffy/sprites/running/luffy_running_sprite_$i.png'))
  //   //           .toList()),
  //   //       stepTime: Globals.luffyRunningSpriteTime,
  //   //     );

  //   // Future<SpriteAnimation> jumping() async => SpriteAnimation.spriteList(
  //   //       await Future.wait([1, 2, 3, 4]
  //   //           .map((i) => Sprite.load(
  //   //               'luffy/sprites/jumping/luffy_jumping_sprite_$i.png'))
  //   //           .toList()),
  //   //       stepTime: Globals.luffyJumpingSpriteTime,
  //   //       loop: true,
  //   //     );
  //   // // return SpriteAnimation.fromFrameData(
  //   // //   game.images.fromCache('Main Characters/$character/$state (32x32).png'),
  //   // //   SpriteAnimationData.sequenced(
  //   // //     amount: amount,
  //   // //     stepTime: stepTime,
  //   // //     textureSize: Vector2.all(32),
  //   // //   ),
  //   // // );
  // }

  SpriteAnimation _specialSpriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$state (96x96).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(96),
        loop: false,
      ),
    );
  }

  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;

    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }

    // Check if moving, set running
    if (velocity.x > 0 || velocity.x < 0) playerState = PlayerState.running;

    // check if Falling set to falling
    if (velocity.y > 0) playerState = PlayerState.falling;

    // Checks if jumping, set to jumping
    if (velocity.y < 0) playerState = PlayerState.jumping;

    current = playerState;
  }

  void _updatePlayerMovement(double dt) {
    if (hasJumped && isOnGround) _playerJump(dt);

    // if (velocity.y > _gravity) isOnGround = false; // optional

    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;
  }

  void _playerJump(double dt) {
    if (game.playSounds) {
      FlameAudio.play('jump.wav', volume: game.soundVolume * 0.3);
    }
    velocity.y = -_jumpForce;
    position.y += velocity.y * dt;
    isOnGround = false;
    hasJumped = false;
  }

  void _checkHorizontalCollisions() {
    for (final block in collisionBlocks) {
      if (!block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.x > 0) {
            velocity.x = 0;
            position.x = block.x - hitbox.offsetX - hitbox.width;
            break;
          }
          if (velocity.x < 0) {
            velocity.x = 0;
            position.x = block.x + block.width + hitbox.width + hitbox.offsetX;
            break;
          }
        }
      }
    }
  }

  void _applyGravity(double dt) {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_jumpForce, _terminalVelocity);
    position.y += velocity.y * dt;
  }

  void _checkVerticalCollisions() {
    for (final block in collisionBlocks) {
      if (block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
        }
      } else {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
          if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.y + block.height - hitbox.offsetY;
          }
        }
      }
    }
  }

  void _respawn() async {
    if (game.playSounds) {
      FlameAudio.play('hit.wav', volume: game.soundVolume * 0.5);
    }
    const canMoveDuration = Duration(milliseconds: 400);
    gotHit = true;
    current = PlayerState.hit;

    await animationTicker?.completed;
    animationTicker?.reset();

    scale.x = 1;
    position = startingPosition - Vector2.all(32);
    current = PlayerState.appearing;

    await animationTicker?.completed;
    animationTicker?.reset();

    velocity = Vector2.zero();
    position = startingPosition;
    _updatePlayerState();
    Future.delayed(canMoveDuration, () => gotHit = false);
  }

  void _reachedCheckpoint() async {
    reachedCheckpoint = true;
    if (game.playSounds) {
      FlameAudio.play('disappear.wav', volume: game.soundVolume * 0.2);
    }
    if (scale.x > 0) {
      position = position - Vector2.all(32);
    } else if (scale.x < 0) {
      position = position + Vector2(32, -32);
    }

    current = PlayerState.disappearing;

    await animationTicker?.completed;
    animationTicker?.reset();

    reachedCheckpoint = false;
    position = Vector2.all(-640);

    const waitToChangeDuration = Duration(seconds: 3);
    await Future.delayed(
        waitToChangeDuration, () async => await game.loadNextLevel());
  }

  void collidedwithEnemy() {
    _respawn();
  }
}
