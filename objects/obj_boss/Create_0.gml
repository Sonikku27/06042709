
is_host = (global.net_role != "client");
mask_index = spr_playerCol;
phase = FP_INTRO;
last_phase = -1;
ph_t = 0;
bhp = BOSS_HP_MAX;
php = [PLAYER_HP_MAX, PLAYER_HP_MAX];   // vida: [host, cliente]
pinv = [0, 0];
tx = x;
ty = y;
face = 1;
anim = BA_IDLE;
idx = 0;
flash = 0;
st = 0;            // 0 idle/correr, 1 punetazo, 2 rodar, 3 salto, 4 golpeado, 5 caido
st_t = 30;
vx = 0;
vy = 0;
binv = 0;
hit_done = [false, false];
music = -1;
ax = x;              // centro de la arena
counter_cd = 0;      // espera entre contraataques
bframe = 0;          // frame que manda el host (golpe, aire, rafaga, entrada)
combo = 0;
rage = false;        // con poca vida ataca mas rapido
air_atk = false;
air_f = 0;
intro_voice = false; // para que la voz de la entrada suene una sola vez
if (is_host) {
    while (place_free(x, y + 1) && y < room_height) y++;
    tx = x;
    ty = y;
}
audio_play_sound(snd_static, 10, false);
