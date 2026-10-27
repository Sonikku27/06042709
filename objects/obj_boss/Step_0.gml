
ph_t++;
if (binv > 0) binv--;
if (counter_cd > 0) counter_cd--;
for (var i = 0; i < 2; i++) { if (pinv[i] > 0) pinv[i]--; }

// efectos al cambiar de fase (en ambos lados)
if (phase != last_phase) {
    last_phase = phase;
    if (phase == FP_FIGHT) {
        legacy_audio_stop_music();
        music = audio_play_sound(snd_boss_theme, 10, true);
    }
    if (phase == FP_DOWN || phase == FP_LOSE) {
        if (music != -1) audio_stop_sound(music);
        music = -1;
    }
    // lo derrotaron: suena el sonido de cuando Knuckles se bugea
    if (phase == FP_DOWN) audio_play_sound(snd_enterHiddenLevel, 10, false);
}

// voz de la entrada: suena justo cuando el jefe aparece despues de la estatica
if (!intro_voice && phase == FP_INTRO && ph_t >= 40) {
    intro_voice = true;
    audio_play_sound(voice_eatheart, 10, false);
}

if (is_host) {
    // ---------------------------------------------------------- HOST: IA y reglas
    var _hx = instance_exists(obj_playerMain) ? obj_playerMain.x : x;
    var _hy = instance_exists(obj_playerMain) ? obj_playerMain.y : y;
    var _px = [_hx, obj_net.remote.tx];
    var _py = [_hy, obj_net.remote.ty];
    var _gr = !place_free(x, y + 1);
    rage = (bhp <= BOSS_HP_MAX * 0.35);
    var _cd = rage ? 3 : 8;   // pausa entre ataques

    if (phase == FP_INTRO) {
        if (ph_t >= 100) { phase = FP_FIGHT; ph_t = 0; st = 0; st_t = 30; }
    }
    else if (phase == FP_FIGHT) {
        // objetivo: el jugador vivo mas cercano
        var _t = -1;
        var _bd = 100000;
        for (var i = 0; i < 2; i++) {
            if (php[i] > 0) {
                var _d = abs(_px[i] - x);
                if (_d < _bd) { _bd = _d; _t = i; }
            }
        }
        var _dx = (_t >= 0) ? (_px[_t] - x) : 0;
        var _dy = (_t >= 0) ? (_py[_t] - y) : 0;

        switch (st) {
            case 0:   // correr hacia el jugador / decidir ataque
                if (_t >= 0) face = (_dx >= 0) ? 1 : -1;
                vx = (abs(_dx) > 90) ? face * 11 : 0;
                st_t--;
                if (_gr && st_t <= 0 && _t >= 0) {
                    var _r = random(1);
                    var _near = (abs(_dx) < 140 && abs(_dy) < 110);
                    hit_done = [false, false];
                    air_atk = false;
                    air_f = 0;
                    combo = 0;
                    if (_near) {
                        if (_r < 0.45) { st = 1; st_t = 0; vx = 0; }
                        else if (_r < 0.65) { st = 2; st_t = 24; vx = face * 24; }
                        else if (_r < 0.85) { st = 3; st_t = 0; vy = -24; vx = face * 8; air_atk = true; }
                        else { st = 6; st_t = 0; vx = 0; }
                    } else {
                        if (_r < 0.35) { st = 2; st_t = 24; vx = face * 24; }
                        else if (_r < 0.65) { st = 6; st_t = 0; vx = 0; }
                        else if (_r < 0.9) { st = 3; st_t = 0; vy = -24; vx = face * 12; }
                        else { st_t = 6; }
                    }
                }
                break;

            case 1:   // punetazo: carga, golpea en 8..14, puede encadenar otro
                vx = (st_t >= 6 && st_t <= 10) ? face * 4 : 0;
                st_t++;
                if (st_t >= 8 && st_t <= 14) {
                    var _x1 = x + face * 10;
                    var _x2 = x + face * 105;
                    for (var i = 0; i < 2; i++) {
                        if (php[i] > 0 && !hit_done[i]) {
                            if (_px[i] + 24 > min(_x1, _x2) && _px[i] - 24 < max(_x1, _x2) && abs(_py[i] - y) < 75) {
                                hit_done[i] = true;
                                boss_try_hit(i, face);
                            }
                        }
                    }
                }
                if (st_t >= 22) {
                    if (combo < 1 && _t >= 0 && abs(_dx) < 140 && random(1) < (rage ? 0.6 : 0.4)) {
                        combo++;
                        st_t = 0;
                        hit_done = [false, false];
                        face = (_dx >= 0) ? 1 : -1;
                    } else { st = 0; st_t = _cd; vx = 0; }
                }
                break;

            case 2:   // rodar: embestida en linea recta
                st_t--;
                vx = face * 24;
                for (var i = 0; i < 2; i++) {
                    if (php[i] > 0 && !hit_done[i] && abs(_px[i] - x) < 58 && abs(_py[i] - y) < 70) {
                        hit_done[i] = true;
                        boss_try_hit(i, face);
                    }
                }
                if (st_t <= 0) { st = 0; st_t = _cd + 6; vx = 0; }
                break;

            case 3:   // salto: se apunta en el aire; ataque aereo (tajo) o caida giratoria
                st_t++;
                if (_t >= 0) { vx = sign(_dx) * ((abs(_dx) > 40) ? 12 : 4); face = (_dx >= 0) ? 1 : -1; }
                if (air_atk && !_gr && vy > -10) air_f++;
                var _hit_air = false;
                if (air_atk) _hit_air = (air_f >= 4 && air_f <= 16);
                else _hit_air = (vy > 0);
                if (_hit_air) {
                    var _rw = air_atk ? 72 : 58;
                    var _rh = air_atk ? 78 : 70;
                    for (var i = 0; i < 2; i++) {
                        if (php[i] > 0 && !hit_done[i] && abs(_px[i] - x) < _rw && abs(_py[i] - y) < _rh) {
                            hit_done[i] = true;
                            boss_try_hit(i, face);
                        }
                    }
                }
                if (_gr && vy >= 0 && st_t > 3) { st = 0; st_t = _cd + 4; vx = 0; air_f = 0; }
                break;

            case 4:   // golpeado
                st_t--;
                vx *= 0.8;
                if (st_t <= 0) { st = 0; st_t = 3; }
                break;

            case 6:   // rafaga de energia: carga 14 steps, dispara, se recupera
                vx = 0;
                if (_t >= 0 && st_t < 6) face = (_dx >= 0) ? 1 : -1;
                st_t++;
                if (st_t == 14) boss_spawn_blast(x + face * 50, y - 6, face);
                if (st_t >= 32) { st = 0; st_t = _cd; }
                break;
        }
        if (php[0] <= 0 && php[1] <= 0) { phase = FP_LOSE; ph_t = 0; st = 0; vx = 0; }
    }
    else if (phase == FP_DOWN) {
        vx = 0;
        if (ph_t >= 330) { ph_t = -100000; room_goto(rm_select2); }   // gano: siguiente zona
    }
    else if (phase == FP_LOSE) {
        vx = 0;
        if (ph_t >= 120) {
            ph_t = -100000;
            if (obj_net.connected) {
                var _m = net_new_msg(MSG_FCMD);
                buffer_write(_m, buffer_u8, FC_LOSE);
                buffer_write(_m, buffer_f32, 0);
                buffer_write(_m, buffer_f32, 0);
                net_peer_send(_m);
            }
            room_restart();   // perdieron: el nivel vuelve a empezar
        }
    }

    // ---- fisica
    if (!_gr) vy += 1.5;
    else if (vy > 0) vy = 0;
    var _mx = round(vx);
    var _sx = sign(_mx);
    repeat (abs(_mx)) {
        if (place_free(x + _sx, y)) x += _sx;
        else { vx = 0; if (st == 2) st_t = min(st_t, 4); break; }
    }
    var _my = round(vy);
    var _sy = sign(_my);
    repeat (abs(_my)) {
        if (place_free(x, y + _sy)) y += _sy;
        else { vy = 0; break; }
    }

    // ---- animacion que se manda al cliente
    bframe = 0;
    switch (st) {
        case 0: anim = (abs(vx) > 0.5) ? BA_WALK : BA_IDLE; break;
        case 1: anim = BA_PUNCH; bframe = min(5, st_t div 4); break;
        case 2: anim = BA_ROLL; break;
        case 3:
            if (air_atk && air_f > 0) { anim = BA_AIR; bframe = min(6, air_f div 3); }
            else anim = BA_JUMP;
            break;
        case 4: anim = BA_HURT; break;
        case 6: anim = BA_BLAST; bframe = (st_t < 14) ? 0 : 1; break;
        default: anim = BA_DOWN; break;
    }
    if (phase == FP_DOWN) anim = BA_DOWN;
    if (phase == FP_INTRO) { anim = BA_ENTR; bframe = clamp((ph_t - 40) div 10, 0, 5); }
    flash = (binv > 0) ? 1 : 0;

    // ---- estado hacia el cliente (30 veces por segundo aprox.)
    if (obj_net.connected && (ph_t mod 2) == 0) {
        var _b = net_new_msg(MSG_BOSS);
        buffer_write(_b, buffer_u8, phase);
        buffer_write(_b, buffer_f32, x);
        buffer_write(_b, buffer_f32, y);
        buffer_write(_b, buffer_s8, face);
        buffer_write(_b, buffer_u8, anim);
        buffer_write(_b, buffer_u8, bhp);
        buffer_write(_b, buffer_u8, php[0]);
        buffer_write(_b, buffer_u8, php[1]);
        buffer_write(_b, buffer_u8, flash);
        buffer_write(_b, buffer_u8, bframe);
        net_peer_send(_b);
    }
} else {
    // ---------------------------------------------------------- CLIENTE: solo sigue al host
    x = lerp(x, tx, 0.5);
    y = lerp(y, ty, 0.5);
}

// animacion de los sprites
switch (anim) {
    case BA_IDLE: idx += 0.12; break;
    case BA_WALK: idx += 0.4; break;
    case BA_ROLL: case BA_JUMP: idx += 0.6; break;
    case BA_PUNCH: case BA_AIR: case BA_BLAST: case BA_ENTR: idx = bframe; break;
    default: idx = 0;
}
