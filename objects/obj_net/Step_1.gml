
// ---- BEGIN STEP: entrada de chat y menu (antes de los eventos de teclado del resto del juego)
var _in_menu = (room == rm_select1 && global.net_state != "ingame");

if (chat_open) {
    var _enter = keyboard_check_pressed(vk_enter);
    var _esc = keyboard_check_pressed(vk_escape);
    chat_input = string_copy(keyboard_string, 1, 48);
    if (_enter) {
        if (string_length(string_replace_all(chat_input, " ", "")) > 0) chat_say(chat_input);
        chat_open = false;
    } else if (_esc) {
        chat_open = false;
    }
    io_clear();   // el juego no recibe las teclas mientras escribes
    keyboard_string = chat_open ? chat_input : "";
    if (!chat_open) chat_input = "";
}
else if (keyboard_check_pressed(ord("T")) && !(_in_menu && (global.net_state == "ip" || global.net_state == "name"))) {
    chat_open = true;
    chat_input = "";
    io_clear();
    keyboard_string = "";
}
else if (_in_menu) {
    var _up = keyboard_check_pressed(vk_up);
    var _dn = keyboard_check_pressed(vk_down);
    var _lf = keyboard_check_pressed(vk_left);
    var _rt = keyboard_check_pressed(vk_right);
    var _ok = keyboard_check_pressed(vk_enter);
    var _esc2 = keyboard_check_pressed(vk_escape);

    switch (global.net_state) {
        case "menu":
            if (_up) menu_sel = (menu_sel + 2) mod 3;
            if (_dn) menu_sel = (menu_sel + 1) mod 3;
            if (_ok) {
                status = "";
                if (menu_sel == 0) start_host();
                else if (menu_sel == 1) global.net_state = "ip";
                else { global.net_state = "name"; keyboard_string = global.net_name; }
            }
            break;

        case "name":
            var _nm = "";
            var _rawn = keyboard_string;
            for (var i = 1; i <= string_length(_rawn); i++) {
                var _cn = string_char_at(_rawn, i);
                if (ord(_cn) >= 32) _nm += _cn;
            }
            global.net_name = string_copy(_nm, 1, 12);
            if (_ok || _esc2) {
                ini_open("sonicexe_net.ini");
                ini_write_string("net", "name", global.net_name);
                ini_close();
                global.net_state = "menu";
            }
            break;

        case "ip":
            // solo numeros y puntos
            var _raw = keyboard_string;
            var _clean = "";
            for (var i = 1; i <= string_length(_raw); i++) {
                var _c = string_char_at(_raw, i);
                if (string_pos(_c, "0123456789.") > 0) _clean += _c;
            }
            ip_text = string_copy(_clean, 1, 15);
            if (_ok) start_join();
            else if (_esc2) { global.net_state = "menu"; status = ""; }
            break;

        case "waiting":
        case "connecting":
            if (_esc2) { net_close(); status = ""; }
            break;

        case "pick":
            if ((_lf || _rt) && !local_locked) pick_sel = 1 - pick_sel;
            if (_ok && !local_locked) {
                if (remote_locked && remote.skin == pick_sel) {
                    status = "ESE PERSONAJE YA LO ELIGIO TU PAREJA";
                } else {
                    local_locked = true;
                    global.net_skin = (pick_sel == 1) ? "amy" : "sonic";
                    global.net_skin_on = true;
                    status = "";
                    net_send_skin(global.net_skin);
                }
            }
            break;
    }
    io_clear();
    if (global.net_state == "ip") keyboard_string = ip_text;
    if (global.net_state == "name") keyboard_string = global.net_name;
}
