if (!net_gate(object_index)) exit;
with (obj_robotnikSpriteMask)
    action_kill_object();

with (obj_playerMain)
    action_kill_object();

legacy_audio_stop_music();
action_end_sound(8);
createStatic(120);
action_set_alarm(120, 0);

