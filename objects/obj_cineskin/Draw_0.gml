
if (!global.net_skin_on) exit;
var _sk = net_skin_id(global.net_skin);
var _tf = gpu_get_texfilter();
with (all) {
    if (object_index != obj_cineskin && variable_instance_exists(id, "cine_hide")) {
        var _k = net_cine_kind(sprite_index);
        if (cine_hide && _k != 0) {
            var _sx = abs(image_xscale);
            var _fx = x + (-sprite_get_xoffset(sprite_index) + (sprite_get_bbox_left(sprite_index) + sprite_get_bbox_right(sprite_index) + 1) * 0.5) * _sx;
            var _fy = y + (-sprite_get_yoffset(sprite_index) + sprite_get_bbox_bottom(sprite_index) + 1) * image_yscale;
            var _an = net_cine_anim(sprite_index);            // caminar / asustado / golpeado / quieto
            var _fc = net_cine_face(sprite_index, image_xscale);
            var _ix = (_an == NA_WALK) ? (current_time * 0.012) : 0;   // ciclo de caminata ~12 frames por segundo
            net_draw_skin(_sk, _an, _fc, _ix, _fx, _fy);
        }
    }
}
