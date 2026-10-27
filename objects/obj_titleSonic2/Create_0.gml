if (instance_exists(obj_hillBGMain)) obj_hillBGMain.depth = 1000;
if (instance_exists(obj_hillWater)) obj_hillWater.depth = 10001;
image_speed = 0.12;

with (obj_hillWaterfallLarge)
    action_move("000100000", 2);

with (obj_hillWaterfallMid)
    action_move("000100000", 2);

with (obj_hillWaterfallSmall)
    action_move("000100000", 2);

with (obj_hillBGMain)
    action_move("000100000", 2);

with (obj_hillWater)
    action_move("000100000", 2);

