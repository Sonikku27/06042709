
show = false;
if (!instance_exists(obj_net)) exit;
var _r = obj_net.remote;
if (global.net_state != "ingame" || _r.room != room || _r.seen > 45) { was_shown = false; exit; }

if (!was_shown) { rx = _r.tx; ry = _r.ty; was_shown = true; }
rx = lerp(rx, _r.tx, 0.5);
ry = lerp(ry, _r.ty, 0.5);
if (_r.anim != last_anim) { last_anim = _r.anim; idx = 0; }
var _n = sprite_get_number(net_get_sprite(_r.skin, _r.anim, _r.face));
idx = net_anim_wrap(_r.anim, idx + net_anim_speed(_r.anim, _r.spd), _n);
show = true;

var _m = net_role_mask(global.character);
if (_m != noone) depth = _m.depth - 1;
