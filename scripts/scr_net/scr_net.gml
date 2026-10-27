
// ===== Multijugador Sonic.EXE (Radmin VPN / TCP) =====
#macro NET_PORT 6510
#macro MSG_SKIN 1
#macro MSG_STATE 2
#macro MSG_CHAT 3
#macro MSG_ROOM 4
#macro MSG_START 5
// ids de animacion que se sincronizan por red (Harmony)
#macro NA_STAND 0
#macro NA_WAIT 1
#macro NA_WALK 2
#macro NA_RUN 3
#macro NA_ROLL 4
#macro NA_LOOKUP 5
#macro NA_CROUCH 6
#macro NA_SKID 7
#macro NA_SKIDTURN 8
#macro NA_PUSH 9
#macro NA_PUNCH 10
#macro NA_HURT 11
#macro NA_ATKG 12      // ataque en suelo (pelea contra el jefe)
#macro NA_ATKA 13      // ataque en el aire (pelea contra el jefe)
#macro NA_STANCE 14    // postura de pelea (Sonic)
#macro NA_SCARED 15    // asustado (cinematicas)
#macro MSG_NAME 12
#macro MSG_GATE 13

function net_skin_id(_s) {
    return (_s == "amy") ? 1 : 0;
}

function net_new_msg(_type) {
    var _b = buffer_create(64, buffer_grow, 1);
    buffer_write(_b, buffer_u8, _type);
    return _b;
}

// envia el buffer al otro jugador y lo libera
function net_peer_send(_b) {
    if (instance_exists(obj_net)) {
        if (obj_net.connected && obj_net.peer >= 0) {
            network_send_packet(obj_net.peer, _b, buffer_tell(_b));
        }
    }
    buffer_delete(_b);
}

function net_send_skin(_skin) {
    var _b = net_new_msg(MSG_SKIN);
    buffer_write(_b, buffer_u8, net_skin_id(_skin));
    net_peer_send(_b);
}

function net_send_start() {
    net_peer_send(net_new_msg(MSG_START));
}

function net_send_room(_r) {
    var _b = net_new_msg(MSG_ROOM);
    buffer_write(_b, buffer_u16, _r);
    net_peer_send(_b);
}

function net_send_state(_x, _y, _face, _anim, _skin, _spd, _emo = 0) {
    var _b = net_new_msg(MSG_STATE);
    buffer_write(_b, buffer_u16, room);
    buffer_write(_b, buffer_f32, _x);
    buffer_write(_b, buffer_f32, _y);
    buffer_write(_b, buffer_u8, _face);
    buffer_write(_b, buffer_u8, _anim);
    buffer_write(_b, buffer_u8, _skin);
    buffer_write(_b, buffer_u8, clamp(round(_spd), 0, 255));
    buffer_write(_b, buffer_u8, _emo);
    net_peer_send(_b);
}

function net_role_mask(_role) {
    if (_role == "tails" && instance_exists(obj_tailsSpriteMask)) return obj_tailsSpriteMask.id;
    if (_role == "knux" && instance_exists(obj_knuxSpriteMask)) return obj_knuxSpriteMask.id;
    if (_role == "robotnik" && instance_exists(obj_robotnikSpriteMask)) return obj_robotnikSpriteMask.id;
    return noone;
}

// distancia desde obj_playerMain.y hasta sus pies = base de la mascara de colision (igual para todos los roles)
function net_feet(_role) {
    return sprite_get_bbox_bottom(spr_playerCol) - sprite_get_yoffset(spr_playerCol) + 1;
}

// true si el sprite del mask es el de gameplay normal (no una escena especial)
function net_sprite_normal(_role, _spr) {
    var _list = [];
    if (_role == "tails") _list = [spr_tailsIdleLeft, spr_tailsIdleRight, spr_tailsLeft, spr_tailsRight, spr_tailsJump, spr_tailsJumpLeft];
    else if (_role == "knux") _list = [spr_knuxIdleLeft, spr_knuxIdleRight, spr_knuxLeft, spr_knuxRight, spr_knuxPunchLeft, spr_knuxPunchRight];
    else if (_role == "robotnik") _list = [spr_robotnikIdleLeft, spr_robotnikIdleRight, spr_robotnikLeft, spr_robotnikRight];
    for (var i = 0; i < array_length(_list); i++) {
        if (_list[i] == _spr) return true;
    }
    return false;
}

function net_is_punch_sprite(_spr) {
    return (_spr == spr_knuxPunchLeft || _spr == spr_knuxPunchRight);
}

// _skin: 0 = Sonic, 1 = Amy. _anim: ver NA_*. _face: 1 derecha, 0 izquierda
// Los sprites de Harmony miran a la derecha y se voltean con xscale; solo el golpe usa sprites L/R viejos.
function net_get_sprite(_skin, _anim, _face) {
    if (_skin == 0) {
        switch (_anim) {
            case NA_WAIT: return spr_hp_sonic_wait;
            case NA_WALK: return spr_hp_sonic_walk;
            case NA_RUN: return spr_hp_sonic_run;
            case NA_ROLL: return spr_hp_sonic_roll;
            case NA_LOOKUP: return spr_hp_sonic_lookup;
            case NA_CROUCH: return spr_hp_sonic_lookdown;
            case NA_SKID: return spr_hp_sonic_skid;
            case NA_SKIDTURN: return spr_hp_sonic_skidturn;
            case NA_PUSH: return spr_hp_sonic_push;
            case NA_HURT: return spr_mpSonicHurt;
            case NA_ATKG: return spr_mpSonicAtk;
            case NA_ATKA: return spr_mpSonicAtkAir;
            case NA_STANCE: return _face ? spr_mpSonicPunchR : spr_mpSonicPunchL;
            case NA_SCARED: return spr_mpSonicScared;
            case NA_PUNCH: return _face ? spr_mpSonicPunchR : spr_mpSonicPunchL;
            default: return spr_hp_sonic_idle;
        }
    }
    switch (_anim) {
        case NA_WAIT: return spr_hp_amy_wait;
        case NA_WALK: return spr_hp_amy_walk;
        case NA_RUN: return spr_hp_amy_run;
        case NA_ROLL: return spr_hp_amy_roll;
        case NA_LOOKUP: return spr_hp_amy_lookup;
        case NA_CROUCH: return spr_hp_amy_lookdown;
        case NA_SKID: return spr_hp_amy_skid;
        case NA_SKIDTURN: return spr_hp_amy_skidturn;
        case NA_PUSH: return spr_hp_amy_push;
        case NA_HURT: return spr_mpAmyHurt;
        case NA_ATKG: return spr_mpAmyAtk;
        case NA_ATKA: return spr_mpAmyAtkAir;
        case NA_SCARED: return spr_mpAmyScared;
        case NA_PUNCH: return _face ? spr_mpAmyPunchR : spr_mpAmyPunchL;
        default: return spr_hp_amy_idle;
    }
}

// dibuja una skin con los pies en (_x, _y)
function net_draw_skin(_skin, _anim, _face, _idx, _x, _y, _alpha = 1) {
    var _spr = net_get_sprite(_skin, _anim, _face);
    var _tf = gpu_get_texfilter();
    gpu_set_texfilter(false);   // pixeles nitidos
    if (_anim == NA_PUNCH || _anim == NA_STANCE) {
        draw_sprite_ext(_spr, _idx, _x, _y, 1, 1, 0, c_white, _alpha);
    } else {
        draw_sprite_ext(_spr, _idx, _x, _y, _face ? HP_SCALE : -HP_SCALE, HP_SCALE, 0, c_white, _alpha);
    }
    gpu_set_texfilter(_tf);
}

// frames que avanza la animacion por step de GameMaker. _spd = velocidad * 10 (para caminar/correr/rodar)
// Mismos tiempos que Harmony (duraciones en ticks de 1/60 s).
function net_anim_speed(_anim, _spd = 0) {
    var _t = max(1, round(60 / room_speed));
    var _v = _spd / 10;
    switch (_anim) {
        case NA_WAIT: return _t / 7;
        case NA_WALK:
        case NA_RUN: return _t / (max(0, 8 - _v) + 1);
        case NA_ROLL: return _t / (floor(max(0, 4 - _v)) + 1);
        case NA_LOOKUP:
        case NA_CROUCH:
        case NA_SKID: return 0.4 * _t;
        case NA_SKIDTURN: return 0.3 * _t;
        case NA_PUSH: return 0.1 * _t;
        case NA_PUNCH: return 0.3;
        case NA_ATKG: return 1 / 3;
        case NA_ATKA: return 0.5;
        case NA_STANCE: return 0.15;
    }
    return 0;
}

// mantiene el indice de frame dentro del rango segun el tipo de animacion (loop / sin loop / wait con loop en 2)
function net_anim_wrap(_anim, _idx, _n) {
    if (_n <= 1) return 0;
    switch (_anim) {
        case NA_LOOKUP:
        case NA_CROUCH:
        case NA_SKID:
        case NA_SKIDTURN:
            return min(_idx, _n - 1);
        case NA_WAIT:
            if (_idx >= _n) return min(2, _n - 1) + ((_idx - _n) mod max(1, _n - 2));
            return _idx;
        case NA_PUNCH:
            return _idx;
        case NA_ATKG:
        case NA_ATKA:
            return min(_idx, _n - 1);
    }
    if (_idx >= _n) return _idx - floor(_idx / _n) * _n;
    return _idx;
}


// ===== Emotes: L = beso (Sonic + Amy cerca), K = baile (no hace falta estar cerca) =====
#macro EMO_KISS_DIST 150      // distancia horizontal maxima (px) entre ambos para el beso
#macro EMO_KISS_DY 40         // diferencia de altura maxima (px) para el beso
#macro EMO_HEART_SCALE 1.5    // tamano del icono del corazon
#macro EMO_BANANA_SCALE 1     // tamano del icono de la banana
// estados de emote que se envian por red: 0 nada, 1 corazon (mantiene L), 2 banana (mantiene K), 3 besando, 4 bailando

// icono pequeno (corazon / banana) con animacion en loop
function emo_draw_icon(_kind, _t, _x, _y) {
    var _by = _y + sin(_t * 0.2) * 2;
    if (_kind == 1) {
        var _n = sprite_get_number(spr_emoHeart);
        var _cyc = max(1, _n * 2 - 2);
        var _f = floor(_t * 0.25) mod _cyc;
        if (_f >= _n) _f = _cyc - _f;
        draw_sprite_ext(spr_emoHeart, _f, _x, _by, EMO_HEART_SCALE, EMO_HEART_SCALE, 0, c_white, 1);
    } else {
        var _m = sprite_get_number(spr_emoBanana);
        draw_sprite_ext(spr_emoBanana, floor(_t * 0.35) mod _m, _x, _by, EMO_BANANA_SCALE, EMO_BANANA_SCALE, 0, c_white, 1);
    }
}

// baile de Sonic / Amy con los pies en (_x, _y)
function emo_draw_dance(_skin, _t, _face, _x, _y) {
    var _spr = (_skin == 1) ? spr_mpAmyDance : spr_mpSonicDance;
    var _n = sprite_get_number(_spr);
    var _f = floor(_t * ((_skin == 1) ? 0.33 : 0.25)) mod _n;
    draw_sprite_ext(_spr, _f, _x, _y, _face ? HP_SCALE : -HP_SCALE, HP_SCALE, 0, c_white, 1);
}


// ===== Sprites de escena (Tails / Knuckles / Eggman) -> skin elegida =====
// 0 = no es de escena, 1 = quieto, 2 = golpeado / llorando / muerto
function net_cine_kind(_spr) {
    if (_spr < 0) return 0;
    switch (_spr) {
        case spr_tailsCrying: case spr_tailsDeath: case spr_tailsHorror: case spr_tailsStartCry:
        case spr_knuxDeath: case spr_knuxFright: case spr_knuxGlitch:
            return 2;
        case spr_tailsHappy: case spr_tailsPoke: case spr_tailsPuzzled:
        case spr_tailsScaredLeft: case spr_tailsScaredRight:
        case spr_tailsIdleLeft: case spr_tailsIdleRight: case spr_tailsLeft: case spr_tailsRight:
        case spr_tailsJump: case spr_tailsJumpLeft:
        case spr_knuxIdleLeft: case spr_knuxIdleRight: case spr_knuxLeft: case spr_knuxRight:
        case spr_knuxJump: case spr_knuxPunchLeft: case spr_knuxPunchRight:
        case spr_robotnikIdleLeft: case spr_robotnikIdleRight: case spr_robotnikLeft: case spr_robotnikRight:
            return 1;
    }
    return 0;
}

// los "mask" del jugador los dibuja obj_skin
function net_is_mask_obj(_o) {
    return (_o == obj_tailsSpriteMask || _o == obj_tailsJumpMask || _o == obj_knuxSpriteMask
         || _o == obj_knuxJumpMask || _o == obj_robotnikSpriteMask);
}


// ===== Nombre del jugador =====
function net_send_name() {
    var _b = net_new_msg(MSG_NAME);
    buffer_write(_b, buffer_string, global.net_name);
    net_peer_send(_b);
}

// ===== Eventos de historia que necesitan a los DOS jugadores =====
// Se llama al inicio del evento de colision de un disparador. Devuelve true cuando ambos llegaron.
function net_gate(_obj) {
    if (!global.net_skin_on || global.net_role == "none") return true;
    if (!instance_exists(obj_net)) return true;
    var _o = obj_net;
    if (!_o.connected || global.net_state != "ingame") return true;
    var _n = object_get_name(_obj);
    if (variable_struct_exists(_o.gate_done, _n)) return true;
    if (!variable_struct_exists(_o.gate_local, _n)) {
        variable_struct_set(_o.gate_local, _n, true);
        var _b = net_new_msg(MSG_GATE);
        buffer_write(_b, buffer_string, _n);
        net_peer_send(_b);
    }
    if (variable_struct_exists(_o.gate_remote, _n)) {
        variable_struct_set(_o.gate_done, _n, true);
        _o.gate_wait = false;
        return true;
    }
    _o.gate_wait = true;
    return false;
}


// ===== Ataques de la pelea contra el jefe (X) =====
// _skin: 0 Sonic, 1 Amy. _air: true = ataque en el aire.
// duracion en steps (30 por segundo): suelo Sonic 12 / Amy 15, aire Sonic 6 / Amy 16
function net_atk_len(_skin, _air) {
    if (_air) return (_skin == 1) ? 16 : 6;
    return (_skin == 1) ? 15 : 12;
}

// frame de la animacion de ataque segun los steps transcurridos
function net_atk_frame(_skin, _air, _el) {
    if (_air) return (_skin == 1) ? floor(_el / 2) : 0;
    return floor(_el / 3);
}

// true mientras el golpe hace dano (frames con la zona roja de la hoja de sprites)
function net_atk_active(_skin, _air, _el) {
    var _f = net_atk_frame(_skin, _air, _el);
    if (_air) return (_skin == 1) ? ((_f mod 2) == 1) : true;
    return (_skin == 1) ? (_f == 3) : (_f == 2);
}

// zona de golpe [x1, y1, x2, y2] en pixeles del sprite (sin escalar), mirando a la derecha,
// relativa al punto de los pies. Multiplicar por HP_SCALE y espejar en x segun hacia donde mira.
function net_atk_box(_skin, _air) {
    if (_air) {
        if (_skin == 1) return [-26, -42, 26, 14];
        return [-11, -31, 24, -3];
    }
    if (_skin == 1) return [5.2, -33, 23.2, 3];
    return [-8.4, -35, 19.6, -1];
}

// ===== Cinematicas: animacion de la skin segun el sprite original de la escena =====
// devuelve una animacion NA_*: caminar, asustado, golpeado o quieto
function net_cine_anim(_spr) {
    switch (_spr) {
        case spr_tailsLeft: case spr_tailsRight: case spr_knuxLeft: case spr_knuxRight:
        case spr_robotnikLeft: case spr_robotnikRight:
            return NA_WALK;
        case spr_tailsPoke: case spr_tailsScaredLeft: case spr_tailsScaredRight: case spr_knuxFright:
            return NA_SCARED;
    }
    return (net_cine_kind(_spr) == 2) ? NA_HURT : NA_STAND;
}

// hacia donde mira la escena: 1 derecha, 0 izquierda
function net_cine_face(_spr, _xscale) {
    switch (_spr) {
        case spr_tailsLeft: case spr_knuxLeft: case spr_robotnikLeft:
        case spr_tailsScaredLeft: case spr_tailsIdleLeft: case spr_knuxIdleLeft: case spr_robotnikIdleLeft:
        case spr_tailsJumpLeft: case spr_knuxPunchLeft:
            return 0;
        case spr_tailsRight: case spr_knuxRight: case spr_robotnikRight:
        case spr_tailsScaredRight: case spr_tailsIdleRight: case spr_knuxIdleRight: case spr_robotnikIdleRight:
        case spr_knuxPunchRight:
            return 1;
    }
    return (_xscale >= 0) ? 1 : 0;
}
