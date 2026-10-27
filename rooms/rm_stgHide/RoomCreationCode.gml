if (os_type == os_android)
    instance_create(__view_get( e__VW.XView, 0 ), __view_get( e__VW.YView, 0 ), obj_touchControl);

instance_create(__view_get( e__VW.XView, 0 ), __view_get( e__VW.YView, 0 ), obj_hudMain);
instance_create(__view_get( e__VW.XView, 0 ), __view_get( e__VW.YView, 0 ), obj_score_controller);
instance_create(__view_get( e__VW.XView, 0 ), __view_get( e__VW.YView, 0 ), obj_rings_controller);
instance_create(__view_get( e__VW.XView, 0 ), __view_get( e__VW.YView, 0 ), obj_countup_controller);
instance_create(__view_get( e__VW.XView, 0 ) + 13, __view_get( e__VW.YView, 0 ) + 406, obj_hudIcon);
instance_create(__view_get( e__VW.XView, 0 ), __view_get( e__VW.YView, 0 ), obj_fadeIn);
global.character = "tails";
if (instance_exists(obj_tailsSpriteMask)) obj_tailsSpriteMask.hideandseek = 1;
if (instance_exists(obj_tailsSpriteMask)) obj_tailsSpriteMask.sprite_index = spr_tailsScaredRight;
if (instance_exists(obj_tailsSpriteMask)) obj_tailsSpriteMask.image_speed = 0.2;

// pared izquierda mucho mas alta (con la fisica nueva se podia saltar por encima)
var _wallhi = instance_create_depth(48, -4000, 0, obj_block);
_wallhi.image_yscale = 260;
_wallhi.visible = false;
