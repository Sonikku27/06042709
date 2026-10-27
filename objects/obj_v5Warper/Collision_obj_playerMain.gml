if (!net_gate(object_index)) exit;
with (obj_V5GorePoles)
    instance_destroy();

if (instance_exists(obj_v5ScreamTimer)) obj_v5ScreamTimer.visible = false;
__view_set( e__VW.XView, 0, 600 );//view_xview[0] = 600;
if (instance_exists(obj_playerMain)) obj_playerMain.x = 900;
