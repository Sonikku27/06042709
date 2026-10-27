
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
    var _landed = (_gr && air_prev);   // acaba de aterrizar
    air_prev = !_gr;
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
                if (_landed) { st = 11; st_t = 0; vx = 0; break; }   // aterrizo: se agacha
                if (_t >= 0) face = (_dx >= 0) ? 1 : -1;
                vx = (abs(_dx) > 90) ? face * 11 : 0;
                st_t--;
                if (_gr && st_t <= 0 && _t >= 0) {
                    var _r = random(1);
                    var _near = (abs(_dx) < 140 && abs(_dy) < 110);
                    hit_done = [false, false];
                    air_atk = false;
                    dive = false;
                    air_f = 0;
                    combo = 0;
                    if (random(1) < (rage ? 0.2 : 0.12)) { st = 9; st_t = 0; vx = 0; }   // teletransporte
                    else if (_near) {
                        if (_r < 0.45) { st = 1; st_t = 0; vx = 0; }
                        else if (_r < 0.65) { st = 2; st_t = 24; vx = face * 24; }
                        else if (_r < 0.85) { st = 3; st_t = 0; vy = -24; vx = face * 8; air_atk = true; dive = (random(1) < 0.5); }
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
                // en lo alto del salto: ataque aereo hacia abajo
                if (air_atk && dive && !_gr && vy > -6) { st = 10; st_t = 0; vx = 0; vy = 0; hit_done = [false, false]; break; }
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
                if (_gr && vy >= 0 && st_t > 3) { st = 11; st_t = 0; vx = 0; air_f = 0; }   // aterriza agachado
                break;

            case 4:   // golpeado
                st_t--;
                vx *= 0.8;
                if (st_t <= 0) { st = 0; st_t = 3; }
                break;

            case 7:   // contraataque: pose lenta y despues aparece detras del jugador
                vx = 0;
                if (_t >= 0) face = (_dx >= 0) ? 1 : -1;
                st_t++;
                if (st_t >= 20) {
                    if (_t >= 0) {
                        var _sd = (_px[_t] >= x) ? 1 : -1;      // el jugador esta de este lado del jefe
                        var _nx = _px[_t] + _sd * 80;           // aparece del lado contrario (detras de ti)
                        if (_nx < xmin || _nx > xmax) _nx = _px[_t] - _sd * 80;
                        x = clamp(_nx, xmin, xmax);
                        y = gy;
                        face = (_px[_t] >= x) ? 1 : -1;
                    }
                    vy = 0;
                    st = 8; st_t = 0;
                    hit_done = [false, false];
                }
                break;

            case 8:   // ataque del contraataque: zona invisible a distancia (la hitbox de la hoja)
                vx = 0;
                st_t++;
                if (st_t >= 3 && st_t <= 9) {
                    var _cb = CR_CATK_BOX;
                    var _c1 = x + face * _cb[0] * HP_SCALE;
                    var _c2 = x + face * _cb[2] * HP_SCALE;
                    var _cf = y + net_feet(global.character);
                    for (var i = 0; i < 2; i++) {
                        if (php[i] > 0 && !hit_done[i]) {
                            if (_px[i] + 24 > min(_c1, _c2) && _px[i] - 24 < max(_c1, _c2)
                                && _py[i] + 40 > _cf + _cb[1] * HP_SCALE && _py[i] - 40 < _cf + _cb[3] * HP_SCALE) {
                                hit_done[i] = true;
                                boss_try_hit(i, face);
                            }
                        }
                    }
                }
                if (st_t >= 16) { st = 0; st_t = _cd; }
                break;

            case 9:   // teletransporte: desaparece, reaparece en otro punto de la arena
                vx = 0; vy = 0;
                st_t++;
                if (st_t == 8) {
                    var _tx2;
                    if (_t >= 0 && random(1) < 0.6) _tx2 = _px[_t] + choose(-1, 1) * random_range(90, 260);
                    else _tx2 = random_range(xmin, xmax);
                    var _ty2 = gy;
                    // desde el suelo puede subir; en el aire puede ir a cualquier altura (tambien abajo)
                    if (_gr) { if (random(1) < 0.45) _ty2 = gy - random_range(70, 200); }
                    else { if (random(1) < 0.7) _ty2 = gy - random_range(40, 200); }
                    x = clamp(_tx2, xmin, xmax);
                    y = _ty2;
                    if (_t >= 0) face = (_px[_t] >= x) ? 1 : -1;
                }
                if (st_t >= 14) {
                    if (y < gy - 20 && random(1) < 0.5) { st = 10; st_t = 0; hit_done = [false, false]; }
                    else { st = 0; st_t = _cd; }
                }
                break;

            case 10:   // ataque aereo hacia abajo: se prepara, cae rapido y se queda en el ultimo frame hasta tocar el suelo
                st_t++;
                if (st_t < 8) {
                    vx = 0; vy = 0;
                    if (_t >= 0) face = (_dx >= 0) ? 1 : -1;
                } else {
                    if (st_t == 8) vy = 22;
                    vx = face * 8;
                    vy = min(vy, 30);
                    var _db = (st_t < 12) ? CR_ADOWN_BOX_A : CR_ADOWN_BOX_B;
                    var _d1 = x + face * _db[0] * HP_SCALE;
                    var _d2 = x + face * _db[2] * HP_SCALE;
                    var _df = y + net_feet(global.character);
                    for (var i = 0; i < 2; i++) {
                        if (php[i] > 0 && !hit_done[i]) {
                            if (_px[i] + 24 > min(_d1, _d2) && _px[i] - 24 < max(_d1, _d2)
                                && _py[i] + 40 > _df + _db[1] * HP_SCALE && _py[i] - 40 < _df + _db[3] * HP_SCALE) {
                                hit_done[i] = true;
                                boss_try_hit(i, face);
                            }
                        }
                    }
                    if (_gr && st_t > 9) { st = 11; st_t = 0; vx = 0; vy = 0; }
                }
                break;

            case 11:   // agachado al aterrizar
                vx = 0;
                st_t++;
                if (st_t >= 9) { st = 0; st_t = _cd; }
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
        case 0:
            if (!_gr) { anim = BA_FALL; bframe = (ph_t div 3) mod 3; }
            else anim = (abs(vx) > 0.5) ? BA_WALK : BA_IDLE;
            break;
        case 1: anim = BA_PUNCH; bframe = min(5, st_t div 4); break;
        case 2: anim = BA_ROLL; break;
        case 3:
            if (air_atk && air_f > 0) { anim = BA_AIR; bframe = min(6, air_f div 3); }
            else if (vy > 2) { anim = BA_FALL; bframe = (ph_t div 3) mod 3; }
            else anim = BA_JUMP;
            break;
        case 4: anim = BA_HURT; break;
        case 7: anim = BA_COUNTER; bframe = (st_t div 5) mod 2; break;
        case 8: anim = BA_CATK; break;
        case 9: anim = BA_TELE; break;
        case 10: anim = BA_ADOWN; bframe = (st_t < 4) ? 0 : ((st_t < 8) ? 1 : min(4, 2 + (st_t - 8) div 2)); break;
        case 11: anim = BA_CROUCH; break;
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
    if (abs(tx - x) > 100 || abs(ty - y) > 100) { x = tx; y = ty; }   // teletransporte: sin deslizarse
    else { x = lerp(x, tx, 0.5); y = lerp(y, ty, 0.5); }
}

// animacion de los sprites
switch (anim) {
    case BA_IDLE: idx += 0.12; break;
    case BA_WALK: idx += 0.4; break;
    case BA_ROLL: case BA_JUMP: idx += 0.6; break;
    case BA_PUNCH: case BA_AIR: case BA_BLAST: case BA_ENTR: case BA_COUNTER: case BA_FALL: case BA_ADOWN: idx = bframe; break;
    default: idx = 0;
}
