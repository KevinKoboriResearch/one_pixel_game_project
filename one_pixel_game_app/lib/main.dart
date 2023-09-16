import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:one_pixel_game_app/constants/globals.dart';
import 'package:one_pixel_game_app/constants/sprite_sheets.dart';
import 'package:one_pixel_game_app/games/one_pixel_game.dart';

OnePixelGame _onePixelGame = OnePixelGame();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Pre-load sprite sheets.
  await SpriteSheets.load();

  await FlameAudio.audioCache.loadAll(
    [
      Globals.bgm,
      Globals.luffyJumpSFX,
      Globals.luffyRunningSandalsSFX,
      Globals.pauseSFX,
      Globals.bumpSFX,
      Globals.powerUpAppearsSFX,
      Globals.breakBlockSFX,
    ],
  );

  // FlameAudio.bgm.play(Globals.bgm, volume: 0.1);

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GameWidget(game: _onePixelGame),
    ).animate().fadeIn(
          delay: const Duration(milliseconds: 50),
          duration: const Duration(milliseconds: 400),
        ),
  );
}
