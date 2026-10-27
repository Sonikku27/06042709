
// ---- ROOM START
global.fight_on = false;
gate_local = {};
gate_remote = {};
gate_done = {};
gate_wait = false;
if (global.net_skin_on && !instance_exists(obj_cineskin)) instance_create_depth(0, 0, -15000, obj_cineskin);
if (global.net_skin_on && instance_exists(obj_playerMain)) {
    if (!instance_exists(obj_skin)) instance_create_depth(0, 0, 0, obj_skin);
    if (!instance_exists(obj_remote)) instance_create_depth(0, 0, 0, obj_remote);
    if (!instance_exists(obj_emote)) instance_create_depth(0, 0, 0, obj_emote);
}
if (connected && global.net_role == "host") net_send_room(room);
if (global.net_role == "host" && global.net_state == "ingame") {
    if (room == rm_select1 || room == rm_select2 || room == rm_select3) auto_t = 120;
}
