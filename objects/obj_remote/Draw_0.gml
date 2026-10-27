
if (!show) exit;
if (!instance_exists(obj_net)) exit;
var _r = obj_net.remote;
var _hs = instance_exists(obj_emote) && obj_emote.hide_remote;
if (instance_exists(obj_emote) && obj_emote.hide_remote_all) exit;
if (!_hs) net_draw_skin(_r.skin, _r.anim, _r.face, idx, rx, ry + net_feet(global.character));
draw_set_font(fnt_1);
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_set_color(c_aqua);
draw_text(rx, ry - 50, obj_net.remote_name());
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
