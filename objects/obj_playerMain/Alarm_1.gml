if (global.character == "tails")
{
    if (instance_exists(obj_tailsJumpMask)) obj_tailsJumpMask.visible = false;
    if (instance_exists(obj_tailsSpriteMask)) obj_tailsSpriteMask.visible = true;
}
else if (global.character == "knux")
{
    if (instance_exists(obj_knuxJumpMask)) obj_knuxJumpMask.visible = false;
    if (instance_exists(obj_knuxSpriteMask)) obj_knuxSpriteMask.visible = true;
}
else if (global.character == "sonic")
{
    if (instance_exists(obj_sonicJumpMask)) obj_sonicJumpMask.visible = false;
    if (instance_exists(obj_sonicSpriteMask)) obj_sonicSpriteMask.visible = true;
}

