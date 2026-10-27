
// ---- EMOTES: L = beso, K = baile (ver scr_net: emo_draw_icon / emo_draw_dance)
state = 0;            // 0 nada, 1 corazon (L), 2 banana (K), 3 besando, 4 bailando
last_key = 0;         // 1 = L, 2 = K (la ultima apretada, por si aprietas las dos)
hide_local = false;       // oculta mi sprite normal (lo dibujo yo)
hide_remote = false;      // oculta el sprite normal del otro
hide_remote_all = false;  // oculta tambien su nombre (beso)
kiss_pair = false;
t = 0;
dance_t = 0;
rdance_t = 0;
music = -1;
