// multijugador: solo el host (ya en partida) puede avanzar la seleccion
if (global.net_role == "client" || global.net_state != "ingame") exit;

__background_set( e__BG.HSpeed, 0, 0 );
legacy_audio_stop_music();

with (obj_selectCursor)
    action_sprite_set(spr_selectCursor, 0, 0);

with (obj_selectStatic)
    action_sprite_set(spr_selectStatic, 0, 0);

action_set_alarm(120, 0);

