
if (!show) exit;
if (instance_exists(obj_emote) && obj_emote.hide_local) exit;   // beso / baile: lo dibuja obj_emote
net_draw_skin(net_skin_id(global.net_skin), anim, face, idx, x, y + net_feet(global.character), (inv && ((current_time div 90) mod 2 == 0)) ? 0.35 : 1);
if (global.net_state == "ingame" && instance_exists(obj_net)) {
    draw_set_font(fnt_1);
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    draw_set_color(c_white);
    draw_text(x, y - 50, obj_net.my_name());
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
