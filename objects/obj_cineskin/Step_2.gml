
// oculta los sprites de escena de Tails / Knuckles / Eggman; Draw los dibuja con la skin elegida
if (!global.net_skin_on) exit;
with (all) {
    if (object_index != obj_cineskin && !net_is_mask_obj(object_index)) {
        if (visible && net_cine_kind(sprite_index) != 0) {
            visible = false;
            cine_hide = true;
        }
    }
}
