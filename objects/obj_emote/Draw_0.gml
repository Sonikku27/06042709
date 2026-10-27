
if (!global.net_skin_on || !instance_exists(obj_playerMain) || !instance_exists(obj_net)) exit;
var _p = obj_playerMain;
var _feet = net_feet(global.character);
var _my = net_skin_id(global.net_skin);
var _rm = instance_exists(obj_remote) && obj_remote.show;
var _r = obj_net.remote;
var _lx = _p.x;
var _ly = _p.y + _feet;

// ---- beso: un solo sprite con los dos (Amy siempre encima de Sonic)
if (kiss_pair && _rm) {
    var _rx = obj_remote.rx;
    var _ry = obj_remote.ry + _feet;
    var _sx = (_my == 0) ? _lx : _rx;     // x de Sonic
    var _ax = (_my == 0) ? _rx : _lx;     // x de Amy
    var _flip = (_ax < _sx) ? -1 : 1;     // Sonic a la izquierda, Amy a la derecha
    var _tf = gpu_get_texfilter();
    gpu_set_texfilter(false);   // pixeles nitidos (sin blur)
    draw_sprite_ext(spr_mpKiss, 0, (_lx + _rx) / 2, max(_ly, _ry), HP_SCALE * _flip, HP_SCALE, 0, c_white, 1);
    gpu_set_texfilter(_tf);
    exit;
}

// ---- baile (yo)
if (state == 4) emo_draw_dance(_my, dance_t, obj_skin.face, _lx, _ly);
// ---- baile (el otro)
if (_rm && _r.emo == 4) emo_draw_dance(_r.skin, rdance_t, _r.face, obj_remote.rx, obj_remote.ry + _feet);

// ---- iconos pequenos arriba a la derecha del personaje
if (state == 1 || state == 3) emo_draw_icon(1, t, _lx + 44, _ly - 72);
else if (state == 2) emo_draw_icon(2, t, _lx + 44, _ly - 72);
if (_rm && !hide_remote) {
    if (_r.emo == 1 || _r.emo == 3) emo_draw_icon(1, t + 7, obj_remote.rx + 44, obj_remote.ry + _feet - 72);
    else if (_r.emo == 2) emo_draw_icon(2, t + 7, obj_remote.rx + 44, obj_remote.ry + _feet - 72);
}
