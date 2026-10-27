// ===== Fisica estilo Harmony Framework (Sonic 3 / Mega Drive) para obj_playerMain =====
// Se activa solo cuando el jugador eligio Sonic o Amy (global.net_skin_on).
// Valores tomados de player_handle_physics / player_control / player_state_* de Harmony.
// Las constantes estan en "pixeles por 1/60 s" de Harmony y se multiplican por HP_SCALE
// porque aqui el personaje mide ~80 px (en Harmony ~40 px). Como la sala corre a 30 fps,
// se ejecutan 2 ticks de 1/60 s por step, asi la velocidad real es la de Harmony.
// Sin peel-out, dropdash ni spindash (a proposito).

#macro HP_SCALE 2
#macro HP_STEPUP 6

// estados
#macro HPS_NORMAL 0
#macro HPS_JUMP 1
#macro HPS_ROLL 2
#macro HPS_LOOKUP 3
#macro HPS_CROUCH 4

function hp_init() {
    hp_on = global.net_skin_on;
    hp_gsp = 0;            // velocidad en el suelo
    hp_xsp = 0;            // velocidad horizontal en el aire
    hp_ysp = 0;            // velocidad vertical
    hp_rx = 0;             // restos de subpixel
    hp_ry = 0;
    hp_state = HPS_NORMAL;
    hp_face = 1;           // 1 derecha, -1 izquierda
    hp_skid = 0;
    hp_idle = 0;
    hp_jumpflag = false;
    hp_jdur = 0;
    hp_ground = !place_free(x, y + 1);
    hp_emote = false;      // true mientras besa / baila: no se puede mover
    hp_freeze = false;     // congelado (intro del jefe)
    hp_hurt = 0;           // steps de golpeado (sin control)
    hp_inv = 0;            // steps de invulnerabilidad tras un golpe
    hp_dead = false;       // sin vida en la pelea
    hp_anim = -1;
    hp_frame = 0;
    hp_sub = 0;
    hp_dur = 0;
    hp_spd = 0;
    hp_usedur = false;
    hp_loop = true;
    hp_lf = 0;
    hp_fin = false;
    hp_ticks = max(1, round(60 / room_speed));
    hp_play(NA_STAND);
}

// cambia de animacion (si ya es esa, no la reinicia) -- equivale a animation_play de Harmony
function hp_play(_a) {
    if (hp_anim == _a) return;
    hp_anim = _a;
    hp_frame = 0;
    hp_sub = 0;
    hp_fin = false;
    hp_dur = 0;
    hp_spd = 0;
    hp_usedur = false;
    hp_loop = true;
    hp_lf = 0;
    switch (_a) {
        case NA_STAND:    hp_spd = 0.2; break;
        case NA_WAIT:     hp_usedur = true; hp_dur = 6; hp_lf = 2; break;
        case NA_WALK:     hp_usedur = true; hp_dur = 7; break;
        case NA_RUN:      hp_usedur = true; hp_dur = 2; break;
        case NA_ROLL:     hp_usedur = true; hp_dur = 0; break;
        case NA_LOOKUP:   hp_spd = 0.4; hp_loop = false; break;
        case NA_CROUCH:   hp_spd = 0.4; hp_loop = false; break;
        case NA_SKID:     hp_spd = 0.4; hp_loop = false; break;
        case NA_SKIDTURN: hp_spd = 0.3; hp_loop = false; break;
        case NA_PUSH:     hp_spd = 0.1; break;
    }
}

// avanza la animacion 1 tick (igual que animator_update de Harmony)
function hp_anim_tick() {
    var _n = sprite_get_number(net_get_sprite(net_skin_id(global.net_skin), hp_anim, 1));
    if (!hp_usedur) {
        hp_frame += hp_spd;
    } else {
        if (hp_sub < hp_dur) hp_sub++;
        else { hp_frame++; hp_sub = 0; }
    }
    if (hp_frame < _n - 1) hp_fin = false;
    if (hp_frame >= _n) {
        if (hp_loop) { hp_frame = min(hp_lf, _n - 1); hp_fin = true; }
        else { hp_frame = _n - 1; hp_fin = true; }
    }
}

function hp_approach(_v, _t, _s) {
    if (_v < _t) return min(_v + _s, _t);
    return max(_v - _s, _t);
}

// mascara de colision: normal (spr_playerCol) o reducida al rodar/saltar (mismo suelo)
function hp_mask(_roll) {
    if (_roll) {
        mask_index = spr_hp_colroll;
    } else {
        mask_index = spr_playerCol;
        if (!place_free(x, y)) mask_index = spr_hp_colroll;   // techo encima: se queda chico
    }
}

function hp_do_jump() {
    hp_ysp -= (global.net_skin == "amy") ? 6.9 : 6.5;
    hp_xsp = hp_gsp;
    hp_jumpflag = true;
    hp_ground = false;
    hp_state = HPS_JUMP;
    hp_idle = 0;
    hp_jdur = floor(max(0, 4 - abs(hp_gsp)));
    hp_play(NA_ROLL);
    hp_dur = hp_jdur;
    hp_mask(true);
    audio_play_sound(snd_hp_jump, 10, false);
}

function hp_can_jump() {
    return (hp_ground && place_free(x, y - 1));   // sin restricciones por nivel / personaje
}

function hp_start_roll() {
    hp_state = HPS_ROLL;
    hp_idle = 0;
    hp_play(NA_ROLL);
    hp_mask(true);
    audio_play_sound(snd_hp_roll, 10, false);
}

// 1 tick de 1/60 s
function hp_tick(_mov, _down, _up, _jp, _jh) {
    var _acc = 0.046875, _dec = 0.5, _frc = 0.046875, _top = (global.net_skin == "amy") ? 5.4 : 6, _grv = 0.21875, _rel = 4, _rfrc = 0.0234375;
    var _ctl = true;     // movement_allow
    var _dir = true;     // direction_allow
    var _dyn = -1;       // duracion de animacion dinamica

    // si el suelo desaparecio mientras mira arriba/abajo
    if (!hp_ground && (hp_state == HPS_LOOKUP || hp_state == HPS_CROUCH)) hp_state = HPS_NORMAL;

    if (hp_ground && hp_gsp == 0) hp_idle++; else hp_idle = 0;

    switch (hp_state) {
        // ------------------------------------------------------------ NORMAL
        case HPS_NORMAL:
            if (hp_ground && abs(hp_gsp) < 0.5 && _up && !_down) { hp_state = HPS_LOOKUP; hp_idle = 0; break; }
            if (hp_ground && abs(hp_gsp) < 0.5 && _down && !_up) { hp_state = HPS_CROUCH; hp_idle = 0; break; }
            if (hp_skid <= 0) {
                var _a = NA_STAND;
                if (!hp_ground) _a = NA_WALK;
                if (abs(hp_gsp) > 0 && abs(hp_gsp) <= 6) { _a = NA_WALK; if (hp_ground) _dyn = max(0, 8 - abs(hp_gsp)); }
                if (abs(hp_gsp) >= 6) { _a = NA_RUN; if (hp_ground) _dyn = max(0, 8 - abs(hp_gsp)); }
                if (hp_idle > 160) _a = NA_WAIT;
                // derrape
                if (abs(hp_gsp) > 4 && hp_ground && _mov == -sign(hp_gsp)) {
                    hp_skid = 24;
                    hp_face = sign(hp_gsp);
                    audio_play_sound(snd_hp_skid, 10, false);
                }
                // empujar pared
                if (_mov == hp_face && hp_ground && abs(hp_gsp) <= _acc + 0.5 && !place_free(x + hp_face, y)) _a = NA_PUSH;
                hp_play(_a);
                if (_dyn >= 0) hp_dur = _dyn;
            } else {
                _dir = false;
                if (!hp_ground) hp_skid = 0;
                if (sign(hp_gsp) == hp_face) {
                    hp_play(NA_SKID);
                } else {
                    hp_play(NA_SKIDTURN);
                    if (hp_fin) { hp_play(NA_WALK); hp_skid = 0; hp_face *= -1; }
                }
                if (_mov == hp_face || _mov == 0) hp_skid--;
            }
            // rodar / saltar
            if (hp_ground && _down && abs(hp_gsp) > 1) { hp_start_roll(); break; }
            if (_jp && hp_can_jump()) { hp_do_jump(); break; }
        break;

        // ------------------------------------------------------------ SALTO
        case HPS_JUMP:
            if (hp_ground) { hp_state = HPS_NORMAL; hp_mask(false); break; }
            if (!_jh && hp_ysp < -_rel && hp_jumpflag) { hp_jumpflag = false; hp_ysp = -_rel; }
            hp_play(NA_ROLL);
            hp_dur = hp_jdur;
        break;

        // ------------------------------------------------------------ RODAR
        case HPS_ROLL:
            hp_play(NA_ROLL);
            if (hp_ground) {
                hp_dur = floor(max(0, 4 - abs(hp_gsp)));
                _ctl = false;
                hp_gsp = hp_approach(hp_gsp, 0, _rfrc);
                if (_jp && hp_can_jump()) { hp_do_jump(); break; }
                if (hp_gsp == 0) { hp_state = HPS_NORMAL; hp_mask(false); break; }
                if (_mov == -sign(hp_gsp)) hp_gsp -= 0.125 * -_mov;
                hp_gsp = clamp(hp_gsp, -18, 18);
            }
        break;

        // ------------------------------------------------------------ MIRAR ARRIBA
        case HPS_LOOKUP:
            if (_jp && hp_can_jump()) { hp_do_jump(); break; }
            _ctl = false; _dir = false;
            hp_play(NA_LOOKUP);
            hp_gsp = hp_approach(hp_gsp, 0, _frc);
            if (!_up) hp_state = HPS_NORMAL;
        break;

        // ------------------------------------------------------------ AGACHARSE
        case HPS_CROUCH:
            _ctl = false; _dir = false;
            hp_play(NA_CROUCH);
            hp_gsp = hp_approach(hp_gsp, 0, _frc);
            if (!_down) { hp_state = HPS_NORMAL; break; }
            if (_jp && hp_can_jump()) { hp_do_jump(); break; }
        break;
    }

    // ------------------------------------------------------------ CONTROL (player_control)
    if (_ctl) {
        if (hp_ground) {
            if (_mov == -1) {
                if (hp_gsp > 0) { hp_gsp -= _dec; if (hp_gsp <= 0) hp_gsp = -_dec; }
                else if (hp_gsp > -_top) hp_gsp -= _acc;
            }
            if (_mov == 1) {
                if (hp_gsp < 0) { hp_gsp += _dec; if (hp_gsp >= 0) hp_gsp = _dec; }
                else if (hp_gsp < _top) hp_gsp += _acc;
            }
            if (_mov == 0) hp_gsp -= min(abs(hp_gsp), _frc) * sign(hp_gsp);
        } else {
            if (hp_ysp > -4 && hp_ysp < 0) hp_xsp -= hp_xsp / 32;      // resistencia del aire
            if (hp_xsp >= -_top && _mov == -1) hp_xsp -= _acc * 2;
            if (hp_xsp <= _top && _mov == 1) hp_xsp += _acc * 2;
        }
    }

    // ------------------------------------------------------------ DIRECCION (player_direction)
    if (_dir) {
        if (hp_ground) {
            if (_mov != 0 && sign(hp_gsp) == _mov) hp_face = _mov;
        } else if (_mov != 0) {
            hp_face = _mov;
        }
    }

    // ------------------------------------------------------------ MOVIMIENTO (player_movement)
    hp_gsp = clamp(hp_gsp, -24, 24);
    hp_xsp = clamp(hp_xsp, -24, 24);
    hp_ysp = clamp(hp_ysp, -24, 24);
    if (hp_ground) hp_xsp = hp_gsp;
    else hp_ysp += _grv;

    // horizontal
    var _dx = hp_xsp * HP_SCALE + hp_rx;
    var _ix = (_dx >= 0) ? floor(_dx) : ceil(_dx);
    hp_rx = _dx - _ix;
    var _sx = sign(_ix);
    repeat (abs(_ix)) {
        if (place_free(x + _sx, y)) {
            x += _sx;
        } else {
            var _ok = false;
            if (hp_ground) {
                for (var k = 1; k <= HP_STEPUP; k++) {
                    if (place_free(x + _sx, y - k) && place_free(x, y - k)) { x += _sx; y -= k; _ok = true; break; }
                }
            }
            if (!_ok) {
                if (hp_ground) hp_gsp = 0;
                hp_xsp = 0;
                hp_rx = 0;
                break;
            }
        }
    }

    // vertical
    if (!hp_ground) {
        var _dy = hp_ysp * HP_SCALE + hp_ry;
        var _iy = (_dy >= 0) ? floor(_dy) : ceil(_dy);
        hp_ry = _dy - _iy;
        var _sy = sign(_iy);
        repeat (abs(_iy)) {
            if (place_free(x, y + _sy)) {
                y += _sy;
            } else {
                if (_sy > 0) { hp_ground = true; hp_gsp = hp_xsp; hp_ysp = 0; }
                else { hp_ysp = 0; }
                hp_ry = 0;
                break;
            }
        }
    } else if (place_free(x, y + 1)) {
        // el suelo bajo los pies: seguir escalones chicos hacia abajo o caer
        var _snap = 0;
        for (var kk = 2; kk <= HP_STEPUP; kk++) {
            if (!place_free(x, y + kk)) { _snap = kk - 1; break; }
        }
        if (_snap > 0) { y += _snap; }
        else { hp_ground = false; hp_xsp = hp_gsp; hp_ysp = 0; hp_ry = 0; }
    }
}

// se llama una vez por step de GameMaker (30 fps) -> 2 ticks de Harmony (60 fps)
function hp_step() {
    hspeed = 0; vspeed = 0; gravity = 0;
    var _mov = keyboard_check(vk_right) - keyboard_check(vk_left);
    var _down = keyboard_check(vk_down);
    var _up = keyboard_check(vk_up);
    var _jp = keyboard_check_pressed(vk_space);
    var _jh = keyboard_check(vk_space);
    if (hp_hurt > 0) hp_hurt--;
    if (hp_inv > 0) hp_inv--;
    if (hp_hurt > 0 || hp_dead) { _mov = 0; _down = false; _up = false; _jp = false; _jh = false; }
    if (hp_emote || hp_freeze) {
        // besando / bailando / intro: quieto y sin controles
        _mov = 0; _down = false; _up = false; _jp = false; _jh = false;
        hp_gsp = 0; hp_xsp = 0; hp_skid = 0;
        if (hp_ground && hp_state != HPS_NORMAL) { hp_state = HPS_NORMAL; hp_mask(false); }
    }
    for (var i = 0; i < hp_ticks; i++) {
        hp_tick(_mov, _down, _up, (i == 0) && _jp, _jh);
        hp_anim_tick();
    }
    // compatibilidad con los objetos "mask" del juego original
    if (_mov > 0) var_direction = "right";
    else if (_mov < 0) var_direction = "left";
    else var_direction = "stopped";
}


// el jugador recibe un golpe del jefe (_dir = 1 empuja a la derecha, -1 a la izquierda)
function hp_hit(_dir) {
    hp_hurt = 30;
    hp_inv = 60;
    hp_state = HPS_NORMAL;
    hp_mask(false);
    hp_ground = false;
    hp_ysp = -3.5;
    hp_xsp = _dir * 3;
    hp_gsp = hp_xsp;
    hp_skid = 0;
}
