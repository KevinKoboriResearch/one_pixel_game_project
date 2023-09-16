import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:one_pixel_game_app/constants/globals.dart';
import 'package:one_pixel_game_app/constants/sprite_sheets.dart';

class AnimationConfigs {
  AnimationConfigs._();

  static GoombaAnimationConfigs goomba = GoombaAnimationConfigs();
  static LuffyCharacterAnimationConfigs luffyCharacter =
      LuffyCharacterAnimationConfigs();
  static BlockConfigs block = BlockConfigs();
}

class BlockConfigs {
  SpriteAnimation mysteryBlockIdle() => SpriteAnimation.variableSpriteList(
        List<Sprite>.generate(
          3,
          (index) => SpriteSheets.itemBlocksSpriteSheet.getSprite(8, 5 + index),
        ),
        stepTimes:
            List<double>.generate(3, (index) => Globals.mysteryBlockStepTime),
      );

  SpriteAnimation mysteryBlockHit() => SpriteAnimation.variableSpriteList(
        [
          SpriteSheets.itemBlocksSpriteSheet.getSprite(7, 8),
        ],
        stepTimes: [
          Globals.mysteryBlockStepTime,
        ],
      );

  SpriteAnimation brickBlockIdle() => SpriteAnimation.variableSpriteList(
        [
          SpriteSheets.itemBlocksSpriteSheet.getSprite(7, 17),
        ],
        stepTimes: [
          Globals.mysteryBlockStepTime,
        ],
      );

  SpriteAnimation brickBlockHit() => SpriteAnimation.variableSpriteList(
        [
          SpriteSheets.itemBlocksSpriteSheet.getSprite(7, 19),
        ],
        stepTimes: [
          double.infinity,
        ],
      );
}

class GoombaAnimationConfigs {
  SpriteAnimation walking() => SpriteAnimation.variableSpriteList(
        List<Sprite>.generate(
          2,
          (index) => SpriteSheets.goombaSpriteSheet.getSprite(0, index),
        ),
        stepTimes:
            List<double>.generate(2, (index) => Globals.goombaSpriteStepTime),
      );

  SpriteAnimation dead() => SpriteAnimation.variableSpriteList(
        [
          SpriteSheets.goombaSpriteSheet.getSprite(0, 2),
        ],
        stepTimes: [
          Globals.goombaSpriteStepTime,
        ],
      );
}

class LuffyCharacterAnimationConfigs {
  Future<SpriteAnimation> idle() async => SpriteAnimation.spriteList(
        await Future.wait([1, 2, 4, 6]
            .map((i) =>
                Sprite.load('luffy/sprites/idle/luffy_idle_sprite_$i.png'))
            .toList()),
        stepTime: Globals.luffyIdleSpriteTime,
      );

  Future<SpriteAnimation> walking() async => SpriteAnimation.spriteList(
        await Future.wait([1, 2, 3, 4, 5, 6]
            .map((i) => Sprite.load(
                'luffy/sprites/running/luffy_running_sprite_$i.png'))
            .toList()),
        stepTime: Globals.luffyRunningSpriteTime,
      );

  Future<SpriteAnimation> jumping() async => SpriteAnimation.spriteList(
        await Future.wait([1, 2, 3, 4]
            .map((i) => Sprite.load(
                'luffy/sprites/jumping/luffy_jumping_sprite_$i.png'))
            .toList()),
        stepTime: Globals.luffyJumpingSpriteTime,
        loop: true,
      );
}
