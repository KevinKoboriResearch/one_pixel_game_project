import 'package:flame/components.dart';
import 'package:one_pixel_game_app/constants/animation_configs.dart';
import 'package:one_pixel_game_app/games/super_mario_bros.dart';
import 'package:one_pixel_game_app/objects/blocks/game_block.dart';

class MysteryBlock extends GameBlock with HasGameRef<SuperMarioBrosGame> {
  bool _hit = false;

  MysteryBlock({
    required Vector2 position,
  }) : super(
          animation: AnimationConfigs.block.mysteryBlockIdle(),
          position: position,
          shouldCrumble: false,
        );

  @override
  void hit() {
    if (!_hit) {
      _hit = true;

      // Updated to empty block animation.
      animation = AnimationConfigs.block.mysteryBlockHit();
    }

    super.hit();
  }
}
