action_set_relative(1);
action_sound(22, 0);
action_sprite_set(spr_sonicKillKnux, 0, 1);
x -= 25;
y -= 26;

with (obj_knuxCry)
    action_create_object(obj_knuxDeath, 0, -23);

action_set_relative(0);

