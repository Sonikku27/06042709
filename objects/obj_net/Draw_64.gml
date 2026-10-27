
// ---- DRAW GUI: menu multijugador + chat
var _gw = display_get_gui_width();
var _gh = display_get_gui_height();
draw_set_font(fnt_1);
var _lh = string_height("M") + 2;
var _blink = ((current_time div 500) mod 2) == 0;

if (room == rm_select1 && global.net_state != "ingame") {
    draw_set_alpha(0.9);
    draw_set_color(c_black);
    draw_rectangle(0, 0, _gw, _gh, false);
    draw_set_alpha(1);
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);

    draw_set_color(c_red);
    draw_text(_gw / 2, _gh * 0.08, "- S O N I C . E X E -");
    draw_set_color(c_white);

    switch (global.net_state) {
        case "menu":
            draw_text(_gw / 2, _gh * 0.22, "MULTIJUGADOR");
            draw_set_color(menu_sel == 0 ? c_red : c_gray);
            draw_text(_gw / 2, _gh * 0.38, (menu_sel == 0 ? "> " : "  ") + "HOSTING");
            draw_set_color(menu_sel == 1 ? c_red : c_gray);
            draw_text(_gw / 2, _gh * 0.48, (menu_sel == 1 ? "> " : "  ") + "JOIN");
            draw_set_color(menu_sel == 2 ? c_red : c_gray);
            draw_text(_gw / 2, _gh * 0.58, (menu_sel == 2 ? "> " : "  ") + "NOMBRE: " + ((global.net_name == "") ? "(SIN NOMBRE)" : global.net_name));
            draw_set_color(c_gray);
            draw_text(_gw / 2, _gh * 0.78, "ARRIBA / ABAJO + ENTER");
            draw_text(_gw / 2, _gh * 0.84, "USA LA IP DE RADMIN VPN DEL HOST");
            break;

        case "name":
            draw_text(_gw / 2, _gh * 0.30, "ESCRIBE TU NOMBRE:");
            draw_set_color(c_yellow);
            draw_text(_gw / 2, _gh * 0.42, global.net_name + (_blink ? "_" : " "));
            draw_set_color(c_gray);
            draw_text(_gw / 2, _gh * 0.62, "ENTER = GUARDAR");
            break;

        case "ip":
            draw_text(_gw / 2, _gh * 0.30, "IP DE RADMIN DEL HOST:");
            draw_set_color(c_yellow);
            draw_text(_gw / 2, _gh * 0.42, ip_text + (_blink ? "_" : " "));
            draw_set_color(c_gray);
            draw_text(_gw / 2, _gh * 0.62, "ENTER = CONECTAR     ESC = VOLVER");
            break;

        case "waiting":
            draw_text(_gw / 2, _gh * 0.30, "ESPERANDO A TU PAREJA" + (_blink ? "..." : ""));
            draw_set_color(c_gray);
            draw_text(_gw / 2, _gh * 0.44, "PASALE TU IP DE RADMIN VPN");
            draw_text(_gw / 2, _gh * 0.50, "PUERTO " + string(NET_PORT));
            draw_text(_gw / 2, _gh * 0.72, "ESC = CANCELAR");
            break;

        case "connecting":
            draw_text(_gw / 2, _gh * 0.36, "CONECTANDO" + (_blink ? "..." : ""));
            draw_set_color(c_gray);
            draw_text(_gw / 2, _gh * 0.72, "ESC = CANCELAR");
            break;

        case "pick":
            draw_text(_gw / 2, _gh * 0.20, "ELIGE A TU PERSONAJE");
            for (var i = 0; i < 2; i++) {
                var _cx = _gw * (i == 0 ? 0.32 : 0.68);
                var _spr = (i == 0) ? spr_mpSonicRender : spr_mpAmyRender;
                var _rsc = max(1, floor(_gh / 480));   // escala entera: sin borrosidad
                var _taken = (remote_locked && remote.skin == i);
                var _mine = (local_locked && pick_sel == i);
                var _sel = (pick_sel == i && !local_locked);
                draw_set_alpha(_taken ? 0.3 : 1);
                var _tf = gpu_get_texfilter();
                gpu_set_texfilter(false);
                draw_sprite_ext(_spr, 0, round(_cx), round(_gh * 0.62), _rsc, _rsc, 0, c_white, draw_get_alpha());
                gpu_set_texfilter(_tf);
                draw_set_alpha(1);
                draw_set_color((_sel || _mine) ? c_red : c_gray);
                draw_text(_cx, _gh * 0.66, (_sel ? "> " : "") + (i == 0 ? "SONIC" : "AMY") + (_sel ? " <" : ""));
                if (_mine) { draw_set_color(c_yellow); draw_text(_cx, _gh * 0.72, "LISTO"); }
                if (_taken) { draw_set_color(c_aqua); draw_text(_cx, _gh * 0.72, "TU PAREJA"); }
            }
            draw_set_color(c_gray);
            if (!local_locked) draw_text(_gw / 2, _gh * 0.86, "IZQ / DER + ENTER");
            else draw_text(_gw / 2, _gh * 0.86, "ESPERANDO AL OTRO JUGADOR" + (_blink ? "..." : ""));
            break;
    }

    if (status != "") {
        draw_set_color(c_red);
        draw_text(_gw / 2, _gh * 0.93, status);
    }
}

// ---- chat (esquina inferior izquierda)
draw_set_halign(fa_left);
draw_set_valign(fa_bottom);
var _n = array_length(chat_lines);
var _shown = chat_open ? 10 : 6;
var _rows = 0;
var _first = max(0, _n - _shown);
for (var i = _first; i < _n; i++) {
    if (chat_open || (current_time - chat_lines[i].born) < 9000) _rows++;
}
var _total = _rows + (chat_open ? 1 : 0);
if (_total > 0) {
    var _boxw = min(_gw - 8, 420);
    draw_set_alpha(0.55);
    draw_set_color(c_black);
    draw_rectangle(4, _gh - 8 - _total * _lh - 4, 4 + _boxw, _gh - 4, false);
    draw_set_alpha(1);
}
var _y = _gh - 8;
if (chat_open) {
    draw_set_color(c_white);
    draw_text(10, _y, "> " + chat_input + (_blink ? "_" : ""));
    _y -= _lh;
}
for (var i = _n - 1; i >= _first; i--) {
    var _age = current_time - chat_lines[i].born;
    if (!chat_open && _age >= 9000) continue;
    var _k = chat_lines[i].kind;
    draw_set_color(_k == 0 ? c_white : (_k == 1 ? c_aqua : c_yellow));
    draw_text(10, _y, chat_lines[i].txt);
    _y -= _lh;
}
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1);

// ---- esperando a que tu pareja llegue a un evento de historia
if (gate_wait && global.net_state == "ingame") {
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_set_color(c_yellow);
    draw_text(_gw / 2, 60, "ESPERANDO A TU PAREJA" + (_blink ? "..." : ""));
    draw_set_color(c_white);
    draw_set_halign(fa_left);
}

// ---- flecha hacia tu pareja cuando esta fuera de pantalla
if (global.net_state == "ingame" && remote.room == room && remote.seen < 90 && instance_exists(obj_playerMain)) {
    var _vx = __view_get( e__VW.XView, 0 );
    var _vy = __view_get( e__VW.YView, 0 );
    var _vw = __view_get( e__VW.WView, 0 );
    var _vh = __view_get( e__VW.HView, 0 );
    var _sx = _gw / _vw;
    var _sy = _gh / _vh;
    var _rx = (remote.tx - _vx) * _sx;
    var _ry = (remote.ty - _vy) * _sy;
    if (_rx < 0 || _rx > _gw || _ry < 0 || _ry > _gh) {
        var _ex = clamp(_rx, 30, _gw - 30);
        var _ey = clamp(_ry, 40, _gh - 40);
        var _dir = point_direction(_gw / 2, _gh / 2, _rx, _ry);
        draw_set_color(c_aqua);
        draw_triangle(_ex + lengthdir_x(14, _dir), _ey + lengthdir_y(14, _dir),
                      _ex + lengthdir_x(10, _dir + 140), _ey + lengthdir_y(10, _dir + 140),
                      _ex + lengthdir_x(10, _dir - 140), _ey + lengthdir_y(10, _dir - 140), false);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        var _ty = (_ey < _gh / 2) ? _ey + 26 : _ey - 26;
        draw_text(clamp(_ex, 60, _gw - 60), _ty, remote_name());
        draw_set_color(c_white);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    }
}
