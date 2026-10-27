
// ===== Mini jefe: Sonic.EXE (Crimson) en hide and seek =====
// El HOST simula al jefe (IA, golpes, vida). El cliente solo lo dibuja con lo que manda el host,
// asi no hay desincronizacion. Los jugadores solo avisan "le pegue" (MSG_HIT) y el host decide.
#macro MSG_BOSS 7
#macro MSG_HIT 8
#macro MSG_HURT 9
#macro MSG_FCMD 10
#macro MSG_FREQ 11
#macro FC_BEGIN 1
#macro FC_LOSE 3
#macro BOSS_HP_MAX 67
#macro PLAYER_HP_MAX 35
#macro FP_INTRO 0
#macro FP_FIGHT 1
#macro FP_DOWN 2
#macro FP_LOSE 3
#macro BA_IDLE 0
#macro BA_WALK 1
#macro BA_ROLL 2
#macro BA_JUMP 3
#macro BA_PUNCH 4
#macro BA_HURT 5
#macro BA_DOWN 6
#macro BA_AIR 7
#macro BA_BLAST 8
#macro BA_ENTR 9
#macro MSG_BLAST 14
#macro BA_COUNTER 10   // pose lenta del contraataque
#macro BA_CATK 11      // ataque del contraataque (zona invisible delante)
#macro BA_TELE 12      // teletransporte
#macro BA_FALL 13      // cayendo
#macro BA_ADOWN 14     // ataque aereo hacia abajo
#macro BA_CROUCH 15    // al aterrizar
// cajas de golpe del jefe [x1,y1,x2,y2] en px de sprite relativos a los pies, mirando a la derecha
#macro CR_CATK_BOX [21, -36, 61, 0]
#macro CR_ADOWN_BOX_A [-10, -29, 21, 3]   // frame 2
#macro CR_ADOWN_BOX_B [-19, -27, 19, 3]   // frames 3 y 4

// el perseguidor atrapo a alguien (o se acabo su tiempo): empieza la pelea
function fight_caught() {
    if (global.fight_on) return;
    if (!instance_exists(obj_playerMain)) return;
    var _x = obj_playerMain.x;
    var _y = obj_playerMain.y;
    if (global.net_role == "client") {
        var _b = net_new_msg(MSG_FREQ);
        buffer_write(_b, buffer_f32, _x);
        buffer_write(_b, buffer_f32, _y);
        net_peer_send(_b);
    } else {
        fight_begin(_x, _y);
    }
}

// se ejecuta en AMBAS maquinas con los mismos datos (_ax, _ay = centro de la arena)
function fight_begin(_ax, _ay) {
    if (global.fight_on) return;
    if (room != rm_stgHide) return;
    global.fight_on = true;
    with (obj_sonicChaseTails) instance_destroy();
    with (obj_staticTransSmall) instance_destroy();
    with (obj_sonicFlashTails) instance_destroy();
    action_end_sound(5);
    legacy_audio_stop_music();

    // paredes invisibles de la arena
    var _w1 = instance_create_depth(_ax - 340, -400, 0, obj_block);
    var _w2 = instance_create_depth(_ax + 308, -400, 0, obj_block);
    with (_w1) { image_xscale = 2; image_yscale = 80; }
    with (_w2) { image_xscale = 2; image_yscale = 80; }

    // cada jugador a su lado
    var _side = (global.net_role == "client") ? 1 : -1;
    if (instance_exists(obj_playerMain)) {
        with (obj_playerMain) {
            x = _ax + _side * 120;
            y = _ay;
            hp_gsp = 0; hp_xsp = 0; hp_ysp = 0;
            hp_state = HPS_NORMAL;
            hp_mask(false);
            hp_ground = !place_free(x, y + 1);
        }
    }
    instance_create_depth(_ax, _ay, 0, obj_boss);
    instance_create_depth(0, 0, 0, obj_fightp);

    if (global.net_role != "client" && instance_exists(obj_net) && obj_net.connected) {
        var _m = net_new_msg(MSG_FCMD);
        buffer_write(_m, buffer_u8, FC_BEGIN);
        buffer_write(_m, buffer_f32, _ax);
        buffer_write(_m, buffer_f32, _ay);
        net_peer_send(_m);
    }
}

// el jefe golpea al jugador _i (0 = host, 1 = cliente). Solo en el host.
function boss_try_hit(_i, _dir) {
    var _b = obj_boss;
    if (_b.php[_i] <= 0 || _b.pinv[_i] > 0) return;
    _b.php[_i] -= 1;
    _b.pinv[_i] = 60;
    if (_i == 0) {
        if (instance_exists(obj_playerMain)) { with (obj_playerMain) hp_hit(_dir); }
    } else {
        var _m = net_new_msg(MSG_HURT);
        buffer_write(_m, buffer_s8, _dir);
        net_peer_send(_m);
    }
    audio_play_sound(snd_knuxPunch, 10, false);
}

// un jugador le pega al jefe. Solo en el host.
function boss_take_hit(_dir) {
    if (!instance_exists(obj_boss)) return;
    var _b = obj_boss;
    if (!_b.is_host || _b.phase != FP_FIGHT || _b.bhp <= 0 || _b.binv > 0) return;
    _b.bhp -= 1;
    _b.binv = 5;
    audio_play_sound(snd_knuxPunch, 10, false);
    if (_b.bhp <= 0) {
        _b.bhp = 0;
        _b.phase = FP_DOWN;
        _b.ph_t = 0;
        _b.st = 5;
        _b.vx = 0;
    } else if (_b.st == 0 || _b.st == 4) {
        // a veces contraataca: pose lenta, aparece detras del jugador y ataca (zona invisible delante)
        if (_b.counter_cd <= 0 && random(1) < (_b.rage ? 0.6 : 0.35)) {
            _b.counter_cd = 110;
            _b.st = 7;
            _b.st_t = 0;
            _b.vx = 0;
            _b.hit_done = [false, false];
        } else {
            _b.st = 4;
            _b.st_t = 7;
            _b.vx = _dir * 5;
        }
    }
}

// crea la rafaga de energia (en ambas maquinas)
function blast_create(_x, _y, _dir) {
    var _p = instance_create_depth(_x, _y, 0, obj_bossblast);
    _p.dir = _dir;
    return _p;
}

// el host dispara una rafaga y avisa al cliente
function boss_spawn_blast(_x, _y, _dir) {
    blast_create(_x, _y, _dir);
    if (instance_exists(obj_net) && obj_net.connected) {
        var _m = net_new_msg(MSG_BLAST);
        buffer_write(_m, buffer_s8, _dir);
        buffer_write(_m, buffer_f32, _x);
        buffer_write(_m, buffer_f32, _y);
        net_peer_send(_m);
    }
}

function fight_draw_bar(_x, _y, _w, _v, _max, _col, _label) {
    draw_set_color(c_black);
    draw_rectangle(_x - 2, _y - 2, _x + _w + 2, _y + 12, false);
    draw_set_color(_col);
    draw_rectangle(_x, _y, _x + _w * clamp(_v / _max, 0, 1), _y + 10, false);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_text(_x + _w + 8, _y - 4, _label);
}
