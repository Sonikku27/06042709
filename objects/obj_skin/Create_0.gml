
face = 1;       // 1 derecha, 0 izquierda
anim = NA_STAND;
idx = 0;
spd = 0;        // velocidad * 10 (para sincronizar la velocidad de la animacion)
show = false;
inv = false;
// ataque con X en los niveles de Knuckles (fuera de la pelea contra el jefe)
katk_t = 0;       // steps que le quedan al ataque
katk_len = 12;    // duracion total del ataque actual
katk_air = false; // true = ataque en el aire
katk_cd = 0;      // espera entre ataques
