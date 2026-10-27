
var _tf = gpu_get_texfilter();
gpu_set_texfilter(false);
draw_sprite_ext(spr_cr2_proj, 1 + (floor(idx) mod 2), x, y + 24, dir * HP_SCALE, HP_SCALE, 0, c_white, 1);
gpu_set_texfilter(_tf);
