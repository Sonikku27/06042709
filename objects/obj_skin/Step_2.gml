
// ---- END STEP: copia el estado de obj_playerMain (fisica Harmony) y lo dibuja con la skin elegida
show = false;
if (!global.net_skin_on) exit;
if (!instance_exists(obj_playerMain)) exit;

var _role = global.character;
var _m = net_role_mask(_role);
if (_m == noone) exit;

var _p = obj_playerMain;
x = _p.x;
y = _p.y;
depth = _m.depth - 1;
inv = (_p.hp_on && _p.hp_inv > 0);

if (_p.hp_on) {
    face = (_p.hp_face > 0) ? 1 : 0;
    var _a = _p.hp_anim;
    var _i = _p.hp_frame;
    // (el golpe viejo de Knuckles ya no se usa con Sonic / Amy: ahora X usa sus sprites de ataque, ver mas abajo)
    // pelea contra el jefe: postura de pelea (solo Sonic) y ataques (X)
    var _sk = net_skin_id(global.net_skin);
    if (instance_exists(obj_fightp) && instance_exists(obj_boss) && _sk == 0
        && (obj_boss.phase == FP_INTRO || obj_boss.phase == FP_FIGHT) && (_a == NA_STAND || _a == NA_WAIT)) {
        _a = NA_STANCE;
        _i = net_anim_wrap(NA_STANCE, ((anim == NA_STANCE) ? idx : 0) + net_anim_speed(NA_STANCE), sprite_get_number(net_get_sprite(0, NA_STANCE, (_p.hp_face > 0) ? 1 : 0)));
    }
    if (instance_exists(obj_fightp) && obj_fightp.atk_t > 0) {
        var _el = obj_fightp.atk_len - obj_fightp.atk_t;
        _a = obj_fightp.atk_air ? NA_ATKA : NA_ATKG;
        _i = net_atk_frame(_sk, obj_fightp.atk_air, _el);
    }
    // niveles de Knuckles (ej. You Can't Run): X ataca en el suelo o en el aire con los mismos sprites
    // de ataque que usan Sonic y Amy en la pelea contra el jefe
    if (katk_cd > 0) katk_cd--;
    if (katk_t > 0) katk_t--;
    if (global.character == "knux" && !instance_exists(obj_fightp)) {
        var _kblock = instance_exists(obj_net) && (obj_net.chat_open || obj_net.gate_wait);
        if (katk_t <= 0 && katk_cd <= 0 && !_kblock && !_p.hp_emote && !_p.hp_freeze
            && !_p.hp_dead && _p.hp_hurt <= 0 && keyboard_check_pressed(ord("X"))) {
            katk_air = !_p.hp_ground;
            katk_len = net_atk_len(_sk, katk_air);
            katk_t = katk_len;
            katk_cd = 4;
            audio_play_sound(snd_knuxPunch, 10, false);
        }
        if (katk_t > 0) {
            _a = katk_air ? NA_ATKA : NA_ATKG;
            _i = net_atk_frame(_sk, katk_air, katk_len - katk_t);
        }
    } else katk_t = 0;
    if (_p.hp_hurt > 0 || _p.hp_dead) { katk_t = 0; _a = NA_HURT; _i = 0; }
    // esperando a la pareja: quieto, girando en loop (salto / spindash)
    var _gw = instance_exists(obj_net) && obj_net.gate_wait;
    if (_gw) {
        _a = NA_ROLL;
        _i = net_anim_wrap(NA_ROLL, ((anim == NA_ROLL) ? idx : 0) + net_anim_speed(NA_ROLL, 40), sprite_get_number(net_get_sprite(net_skin_id(global.net_skin), NA_ROLL, face)));
    }
    if (_a != anim) anim = _a;
    idx = _i;
    spd = round(abs(_p.hp_ground ? _p.hp_gsp : _p.hp_xsp) * 10);
    if (_gw) spd = 40;
} else {
    // respaldo sin fisica Harmony
    var _l = keyboard_check(vk_left);
    var _r = keyboard_check(vk_right);
    if (_l && !_r) face = 0;
    else if (_r && !_l) face = 1;
    var _na = NA_STAND;
    if (net_is_punch_sprite(_m.sprite_index)) _na = NA_PUNCH;
    else if (_p.gravity > 0 && _role != "robotnik") _na = NA_ROLL;
    else if ((_l || _r) && abs(_p.hspeed) > 0.5) _na = NA_WALK;
    if (_na != anim) { anim = _na; idx = 0; }
    idx += net_anim_speed(anim, 40);
    spd = 40;
}
show = true;

// ocultar los sprites originales
with (obj_tailsSpriteMask) visible = false;
with (obj_tailsJumpMask) visible = false;
with (obj_knuxSpriteMask) visible = false;
with (obj_knuxJumpMask) visible = false;
with (obj_robotnikSpriteMask) visible = false;
