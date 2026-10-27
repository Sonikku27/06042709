if (!net_gate(object_index)) exit;
if (instance_exists(obj_playerMain)) obj_playerMain.canJump = 0;
action_kill_object();
action_create_object(obj_sonicFlashTails, __view_get( e__VW.XView, 0 ), __view_get( e__VW.YView, 0 ));

