if (instance_exists(obj_hudMain)) obj_hudMain.alarm[0] = 2;
if (instance_exists(obj_playerMain)) obj_playerMain.canJump = 0;
legacy_audio_stop_music();
action_sound(16, 0);

