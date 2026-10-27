
// ---- ASYNC NETWORKING
var _type = async_load[? "type"];
switch (_type) {
    case network_type_connect:
        // un cliente se conecto a mi servidor (host)
        if (global.net_role == "host") {
            var _sock = async_load[? "socket"];
            if (peer < 0) {
                peer = _sock;
                connected = true;
                global.net_state = "pick";
                chat_add("[sistema] tu pareja se conecto", 2);
                net_send_name();
            } else {
                network_destroy(_sock);   // sala llena
            }
        }
        break;

    case network_type_non_blocking_connect:
        // resultado de mi conexion (cliente)
        if (global.net_role == "client") {
            if (async_load[? "succeeded"]) {
                connected = true;
                global.net_state = "pick";
                chat_add("[sistema] conectado al host", 2);
                net_send_name();
            } else {
                net_close();
                status = "NO SE PUDO CONECTAR. REVISA LA IP, RADMIN Y EL FIREWALL";
            }
        }
        break;

    case network_type_disconnect:
        if (connected) {
            chat_add("[sistema] se perdio la conexion", 2);
            var _was_game = (global.net_state == "ingame");
            net_close();
            if (_was_game) status = "";
        }
        break;

    case network_type_data:
        var _b = async_load[? "buffer"];
        buffer_seek(_b, buffer_seek_start, 0);
        var _t = buffer_read(_b, buffer_u8);
        switch (_t) {
            case MSG_SKIN:
                remote.skin = buffer_read(_b, buffer_u8);
                if (local_locked && remote.skin == net_skin_id(global.net_skin)) {
                    if (global.net_role == "client") {
                        local_locked = false;
                        remote_locked = true;
                        pick_sel = 1 - remote.skin;
                        status = "ESE PERSONAJE YA LO ELIGIO TU PAREJA";
                    } else {
                        remote_locked = false;   // el host tiene prioridad
                    }
                } else {
                    remote_locked = true;
                }
                break;

            case MSG_START:
                global.net_state = "ingame";
                break;

            case MSG_ROOM:
                var _r = buffer_read(_b, buffer_u16);
                if (global.net_role == "client" && global.net_state == "ingame") {
                    if (_r != room && _r != room_previous(room) && room_exists(_r)) room_goto(_r);
                }
                break;

            case MSG_STATE:
                remote.room = buffer_read(_b, buffer_u16);
                remote.tx = buffer_read(_b, buffer_f32);
                remote.ty = buffer_read(_b, buffer_f32);
                remote.face = buffer_read(_b, buffer_u8);
                remote.anim = buffer_read(_b, buffer_u8);
                remote.skin = buffer_read(_b, buffer_u8);
                remote.spd = buffer_read(_b, buffer_u8);
                remote.emo = buffer_read(_b, buffer_u8);
                remote.seen = 0;
                break;

            case MSG_BOSS:
                var _ph = buffer_read(_b, buffer_u8);
                var _bx = buffer_read(_b, buffer_f32);
                var _by = buffer_read(_b, buffer_f32);
                var _bf = buffer_read(_b, buffer_s8);
                var _ba = buffer_read(_b, buffer_u8);
                var _bh = buffer_read(_b, buffer_u8);
                var _h0 = buffer_read(_b, buffer_u8);
                var _h1 = buffer_read(_b, buffer_u8);
                var _bfl = buffer_read(_b, buffer_u8);
                var _bfr = buffer_read(_b, buffer_u8);
                if (instance_exists(obj_boss)) {
                    if (!obj_boss.is_host) {
                        with (obj_boss) {
                            if (phase != _ph) { phase = _ph; ph_t = 0; }
                            tx = _bx; ty = _by; face = _bf; anim = _ba;
                            bhp = _bh; php[0] = _h0; php[1] = _h1; flash = _bfl; bframe = _bfr;
                        }
                    }
                }
                break;

            case MSG_BLAST:
                var _sd = buffer_read(_b, buffer_s8);
                var _sx = buffer_read(_b, buffer_f32);
                var _sy = buffer_read(_b, buffer_f32);
                if (global.net_role == "client" && global.fight_on) blast_create(_sx, _sy, _sd);
                break;

            case MSG_HIT:
                var _hd = buffer_read(_b, buffer_s8);
                if (global.net_role == "host") boss_take_hit(_hd);
                break;

            case MSG_HURT:
                var _kd = buffer_read(_b, buffer_s8);
                if (instance_exists(obj_playerMain)) { with (obj_playerMain) hp_hit(_kd); }
                break;

            case MSG_FCMD:
                var _fc = buffer_read(_b, buffer_u8);
                var _fx = buffer_read(_b, buffer_f32);
                var _fy = buffer_read(_b, buffer_f32);
                if (_fc == FC_BEGIN) fight_begin(_fx, _fy);
                else if (_fc == FC_LOSE) room_restart();
                break;

            case MSG_FREQ:
                var _rx = buffer_read(_b, buffer_f32);
                var _ry = buffer_read(_b, buffer_f32);
                if (global.net_role == "host") fight_begin(_rx, _ry);
                break;

            case MSG_NAME:
                remote_pname = buffer_read(_b, buffer_string);
                break;

            case MSG_GATE:
                var _gn = buffer_read(_b, buffer_string);
                variable_struct_set(gate_remote, _gn, true);
                if (variable_struct_exists(gate_local, _gn) && !variable_struct_exists(gate_done, _gn)) {
                    variable_struct_set(gate_done, _gn, true);
                    gate_wait = false;
                    var _go = asset_get_index(_gn);
                    if (_go >= 0) {
                        if (instance_exists(_go) && instance_exists(obj_playerMain)) {
                            // other debe ser el jugador (los triggers hacen with (other) action_kill_object())
                            with (obj_playerMain) {
                                with (_go) event_perform(ev_collision, obj_playerMain);
                            }
                        }
                    }
                }
                break;

            case MSG_CHAT:
                var _s = buffer_read(_b, buffer_string);
                chat_add(remote_name() + ": " + _s, 1);
                break;
        }
        break;
}
