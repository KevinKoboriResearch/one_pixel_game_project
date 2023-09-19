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
      home: Stack(
        children: [
          GameWidget(game: _onePixelGame),
          Scaffold(
            backgroundColor: Colors.transparent,
            // body: SizedBox(
            //   height: 400,
            //   width: 400,
            //   child: Column(
            //     children: [
            //       Row(
            //         children: [
            //           AspectRatio(
            //             aspectRatio: 1,
            //             child: FloatingActionButton.extended(
            //               onPressed: () {},
            //               label: Image.asset(
            //                   'assets/images/luffy/menu/luffy_menu.png'),
            //             ),
            //           ),
            //           AspectRatio(
            //             aspectRatio: 1,
            //             child: FloatingActionButton.extended(
            //               onPressed: () {},
            //               label: Image.asset(
            //                   'assets/images/luffy/menu/luffy_menu.png'),
            //             ),
            //           ),
            //         ],
            //       ),
            //     ],
            //   ),
            // ),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: AspectRatio(
                aspectRatio: 1,
                child: FloatingActionButton.extended(
                  onPressed: () {},
                  label: Image.asset('assets/images/luffy/menu/luffy_menu.png'),
                ),
              ),
              centerTitle: true,
              title: FloatingActionButton.extended(
                onPressed: () {},
                label: Image.asset('assets/images/luffy/menu/luffy_menu.png'),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: FloatingActionButton.extended(
                      onPressed: () {},
                      label:
                          Image.asset('assets/images/luffy/menu/luffy_menu.png'),
                    ),
                  ),
                ),
              ],
              toolbarHeight: 128,
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {},
              label: Image.asset('assets/images/luffy/menu/luffy_menu.png'),
            ),
          )
        ],
      ),
    ).animate().fadeIn(
          delay: const Duration(milliseconds: 50),
          duration: const Duration(milliseconds: 400),
        ),
  );
}
