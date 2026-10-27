
if (phase == FP_INTRO && ph_t < 40) exit;   // aparece despues de la estatica
var _spr = spr_cr2_idle;
switch (anim) {
    case BA_WALK: _spr = spr_cr2_walk; break;
    case BA_ROLL: case BA_JUMP: _spr = spr_cr2_jump; break;
    case BA_PUNCH: _spr = spr_cr2_attack; break;
    case BA_AIR: _spr = spr_cr2_atkair; break;
    case BA_BLAST: _spr = spr_cr2_blast; break;
    case BA_ENTR: _spr = spr_cr2_entrance; break;
    case BA_HURT: _spr = spr_cr2_hurt; break;
    case BA_DOWN: _spr = spr_cr2_dead; break;
}
var _a = (flash && ((current_time div 70) mod 2 == 0)) ? 0.5 : 1;
var _tf = gpu_get_texfilter();
gpu_set_texfilter(false);   // pixeles nitidos, mismo tamano que Sonic y Amy
draw_sprite_ext(_spr, idx, x, y + net_feet(global.character), (face >= 0 ? 1 : -1) * HP_SCALE, HP_SCALE, 0, c_white, _a);
gpu_set_texfilter(_tf);
