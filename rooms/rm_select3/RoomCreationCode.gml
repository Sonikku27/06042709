if (os_type == os_android)
    instance_create(__view_get( e__VW.XView, 0 ), __view_get( e__VW.YView, 0 ), obj_touchControl);

if (instance_exists(obj_select1)) obj_select1.sprite_index = spr_select3;
instance_create(__view_get( e__VW.XView, 0 ), __view_get( e__VW.YView, 0 ), obj_fadeIn);
legacy_audio_play_music(2, 1);
