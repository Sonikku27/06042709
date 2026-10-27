
var _gw = display_get_gui_width();
var _gh = display_get_gui_height();
draw_set_font(fnt_1);

// TV de estatica al empezar
if (phase == FP_INTRO) {
    var _al = (ph_t < 60) ? 1 : max(0, 1 - (ph_t - 60) / 30);
    draw_sprite_stretched_ext(spr_staticTrans, current_time div 60, 0, 0, _gw, _gh, c_white, _al * 0.9);
}

if (phase != FP_INTRO || ph_t > 60) {
    // barra del jefe
    var _bw = 300;
    var _bx = _gw / 2 - _bw / 2;
    draw_set_color(c_black);
    draw_rectangle(_bx - 2, 8, _bx + _bw + 2, 26, false);
    draw_set_color(c_red);
    draw_rectangle(_bx, 10, _bx + _bw * clamp(bhp / BOSS_HP_MAX, 0, 1), 24, false);
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_text(_gw / 2, 28, "SONIC.EXE");

    // barras de los jugadores
    var _me = (global.net_role == "client") ? 1 : 0;
    var _myname = string_upper(global.net_skin);
    var _ptname = (global.net_skin == "amy") ? "SONIC" : "AMY";
    fight_draw_bar(10, 10, 140, php[_me], PLAYER_HP_MAX, c_lime, _myname);
    fight_draw_bar(10, 34, 140, php[1 - _me], PLAYER_HP_MAX, c_aqua, _ptname);
}

if (phase == FP_LOSE) {
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_red);
    draw_text(_gw / 2, _gh / 2, "- G A M E   O V E R -");
}
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1);
