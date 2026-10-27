
if (!instance_exists(obj_playerMain) || !instance_exists(obj_boss)) exit;
var _b = obj_boss;
var _p = obj_playerMain;
var _me = (global.net_role == "client") ? 1 : 0;
var _sk = net_skin_id(global.net_skin);

_p.hp_freeze = (_b.phase == FP_INTRO || _b.phase == FP_LOSE);
_p.hp_dead = (_b.php[_me] <= 0);

if (cd > 0) cd--;
var _can = (_b.phase == FP_FIGHT && !_p.hp_dead && _p.hp_hurt <= 0 && !_p.hp_emote);

// ataque con X: en el suelo golpe normal, en el aire ataque aereo
if (atk_t > 0) atk_t--;
if (_can && atk_t <= 0 && cd <= 0 && keyboard_check_pressed(ord("X"))) {
    atk_air = !_p.hp_ground;
    atk_len = net_atk_len(_sk, atk_air);
    atk_t = atk_len;
    atk_hit = false;
    cd = 4;
}

// zona de golpe (la zona roja de la hoja de sprites) contra el cuerpo del jefe
if (atk_t > 0 && _can && !atk_hit) {
    var _el = atk_len - atk_t;
    if (net_atk_active(_sk, atk_air, _el)) {
        var _f = (_p.hp_face > 0) ? 1 : -1;
        var _bx = net_atk_box(_sk, atk_air);
        var _feet = _p.y + net_feet(global.character);
        var _xa = _p.x + _f * _bx[0] * HP_SCALE;
        var _xb = _p.x + _f * _bx[2] * HP_SCALE;
        var _ya = _feet + _bx[1] * HP_SCALE;
        var _yb = _feet + _bx[3] * HP_SCALE;
        if (_b.bbox_right > min(_xa, _xb) && _b.bbox_left < max(_xa, _xb)
            && _b.bbox_bottom > min(_ya, _yb) && _b.bbox_top < max(_ya, _yb)) {
            atk_hit = true;
            if (global.net_role == "client") {
                var _m = net_new_msg(MSG_HIT);
                buffer_write(_m, buffer_s8, _f);
                net_peer_send(_m);
                audio_play_sound(snd_knuxPunch, 10, false);
            } else {
                boss_take_hit(_f);
            }
        }
    }
}
// si te golpean o termina la fase, se corta el ataque
if (_p.hp_hurt > 0 || (!_can && _b.phase != FP_FIGHT)) atk_t = 0;
