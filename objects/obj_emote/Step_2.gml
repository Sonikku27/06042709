
// ---- END STEP: decide el estado del emote
t++;
var _prev = state;
var _ok = global.net_skin_on && global.net_state == "ingame" && instance_exists(obj_playerMain)
    && instance_exists(obj_skin) && instance_exists(obj_net) && instance_exists(obj_remote);
if (_ok) _ok = obj_skin.show && obj_net.connected && !obj_net.chat_open && !obj_net.gate_wait;

// teclas
var _want = 0;
if (_ok) {
    if (keyboard_check_pressed(ord("L"))) last_key = 1;
    if (keyboard_check_pressed(ord("K"))) last_key = 2;
    var _l = keyboard_check(ord("L"));
    var _k = keyboard_check(ord("K"));
    if (_l && _k) _want = last_key;
    else if (_l) _want = 1;
    else if (_k) _want = 2;
}

// el otro jugador
var _rm = _ok && obj_remote.show;
var _re = _rm ? obj_net.remote.emo : 0;

var _ns = _want;   // 0, 1 o 2
if (_ok) {
    var _p = obj_playerMain;
    if (_want == 1 && _rm && (_re == 1 || _re == 3)) {
        var _near = abs(obj_remote.rx - _p.x) <= EMO_KISS_DIST && abs(obj_remote.ry - _p.y) <= EMO_KISS_DY;
        if (state == 3 || (_near && _p.hp_ground)) _ns = 3;
    }
    else if (_want == 2 && _rm && (_re == 2 || _re == 4)) {
        if (state == 4 || _p.hp_ground) _ns = 4;
    }
}
state = _ns;

// congelar / liberar al jugador
if (instance_exists(obj_playerMain)) obj_playerMain.hp_emote = (state == 3 || state == 4);

// musica del baile (reemplaza la de fondo)
if (state == 4 && music == -1) {
    audio_pause_all();
    music = audio_play_sound(snd_whatislove, 50, true);
    dance_t = 0;
}
if (state != 4 && music != -1) {
    audio_stop_sound(music);
    music = -1;
    audio_resume_all();
}

// beso: suena "Alright" cuando los dos ya estan besandose
var _kp = (state == 3 && _re == 3);
if (_kp && !kiss_pair) audio_play_sound(snd_alright, 60, false);
kiss_pair = _kp;

// que se dibuja
var _rdance = (_re == 4 && _rm);
hide_local = kiss_pair || (state == 4);
hide_remote = kiss_pair || _rdance;
hide_remote_all = kiss_pair;
if (state == 4) dance_t++;
if (_rdance) rdance_t++; else rdance_t = 0;

if (_ok) depth = obj_skin.depth - 1; else depth = -100;
