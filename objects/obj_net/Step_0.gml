
remote.seen++;

// esperando a la pareja en un evento de historia: el jugador se queda quieto (obj_skin hace el giro en loop)
if (instance_exists(obj_playerMain) && !instance_exists(obj_fightp)) obj_playerMain.hp_freeze = gate_wait;

// el host arranca cuando ambos eligieron personaje
if (global.net_role == "host" && global.net_state == "pick" && connected && local_locked && remote_locked) {
    global.net_state = "ingame";
    net_send_start();
    auto_t = 60;
}

// el host avanza solo las pantallas de seleccion de nivel
if (auto_t > 0) {
    auto_t--;
    if (auto_t == 0) {
        if (instance_exists(obj_selectCursor)) {
            with (obj_selectCursor) event_perform(ev_keypress, vk_enter);
        }
    }
}

// enviar mi estado (30 veces por segundo aprox.)
send_t++;
if (connected && global.net_state == "ingame" && (send_t mod 2) == 0) {
    if (instance_exists(obj_playerMain) && instance_exists(obj_skin)) {
        var _emo = instance_exists(obj_emote) ? obj_emote.state : 0;
        net_send_state(obj_playerMain.x, obj_playerMain.y, obj_skin.face, obj_skin.anim, net_skin_id(global.net_skin), obj_skin.spd, _emo);
    }
}
