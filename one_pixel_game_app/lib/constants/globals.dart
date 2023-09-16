class Globals {
  Globals._();

  /// Sounds
  static const String bgm = 'bgm/one_piece_ost_the_very_very_strongest_bgm.wav';
  static const String bumpSFX = 'smb_bump.wav';
  static const String luffyJumpSFX = 'luffy/luffy_jump_sfx.wav';
  static const String luffyRunningSandalsSFX =
      'luffy/luffy_running_sandals_sfx.wav';
  static const String pauseSFX = 'smb_pause.wav';
  static const String powerUpAppearsSFX = 'smb_powerup_appears.wav';
  static const String breakBlockSFX = 'smb_breakblock.wav';

  /// Step Times
  static const double luffyIdleSpriteTime = 0.3;
  static const double luffyRunningSpriteTime = 0.1;
  static const double luffyJumpingSpriteTime = 0.2;
  
  static const double goombaSpriteStepTime = 0.5;
  static const double mysteryBlockStepTime = 0.2;
  static const double brickBlockStepTime = 0.2;

  /// Sizes
  static const double tileSize = 16; // 16

  /// Levels
  static const lv_1_1 = 'world_1_1_map.tmx';

  /// Sprite Sheets
  static const String blocksSpriteSheet = 'blocks_spritesheet.png';
  static const String goombaSpriteSheet = 'goomba_spritesheet.png';
  static const String luffyWalkSpriteSheet = 'luffy_walk_sprite.png';

  /// Images
  static const String luffyCharacterIdle = 'mario_idle.png';
  static const String luffyCharacterDead = 'mario_dead.png';
  static const String luffyCharacterJump = 'mario_jump.png';
}
