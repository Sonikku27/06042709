if (hp_on) exit;

if (!place_free(x + hspeed, y))
    hspeed = 0;

if (!place_free(x - hspeed, y))
    hspeed = 0;

