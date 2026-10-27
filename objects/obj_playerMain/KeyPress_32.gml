if (hp_on) exit;

if (canJump == 1)
{
    if (!(global.character == "robotnik"))
    {
		if (!place_free(x, y + 1) && place_free(x, y - 1))
        {
            if (global.character == "tails")
            {
                if (instance_exists(obj_tailsJumpMask)) obj_tailsJumpMask.visible = true;
                if (instance_exists(obj_tailsSpriteMask)) obj_tailsSpriteMask.visible = false;
                vspeed -= var_jumpheight;
                audio_play_sound(snd_jump, 10, false);
            }
            
            if (global.character == "knux")
            {
                if (instance_exists(obj_knuxJumpMask)) obj_knuxJumpMask.visible = true;
                if (instance_exists(obj_knuxSpriteMask)) obj_knuxSpriteMask.visible = false;
                vspeed -= var_jumpheight;
                audio_play_sound(snd_jump, 10, false);
            }
            
            alarm[1] = 50;
        }
    }
}

