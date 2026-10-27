if (global.net_skin_on)
{
    var _tf = gpu_get_texfilter();
    gpu_set_texfilter(false);
    draw_sprite_ext((global.net_skin == "amy") ? spr_hudAmy : spr_hudSonic, 0, __view_get( e__VW.XView, 0 ) + 13, __view_get( e__VW.YView, 0 ) + 406, 2, 2, 0, c_white, 1);
    gpu_set_texfilter(_tf);
    exit;
}
if (global.character == "tails")
    draw_sprite(spr_hudTails, -1, __view_get( e__VW.XView, 0 ) + 13, __view_get( e__VW.YView, 0 ) + 406);
else if (global.character == "knux")
    draw_sprite(spr_hudKnux, -1, __view_get( e__VW.XView, 0 ) + 13, __view_get( e__VW.YView, 0 ) + 406);
else if (global.character == "robotnik")
    draw_sprite(spr_hudEgg, -1, __view_get( e__VW.XView, 0 ) + 13, __view_get( e__VW.YView, 0 ) + 406);

