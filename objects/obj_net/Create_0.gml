
persistent = true;
server = -1;          // socket servidor (solo host)
peer = -1;            // socket hacia el otro jugador
connected = false;
ip_text = "26.";
status = "";
menu_sel = 0;         // 0 = HOSTING, 1 = JOIN
pick_sel = 0;         // 0 = Sonic, 1 = Amy
local_locked = false;
remote_locked = false;
chat_open = false;
chat_input = "";
chat_lines = [];
auto_t = -1;
send_t = 0;
global.net_name = "";
ini_open("sonicexe_net.ini");
global.net_name = ini_read_string("net", "name", "");
ini_close();
remote_pname = "";
gate_local = {};
gate_remote = {};
gate_done = {};
gate_wait = false;
remote = { room: -1, tx: 0, ty: 0, face: 1, anim: 0, skin: 1, spd: 0, emo: 0, seen: 999 };

network_set_config(network_config_connect_timeout, 6000);

chat_add = function(_txt, _kind) {
    array_push(chat_lines, { txt: _txt, kind: _kind, born: current_time });
    if (array_length(chat_lines) > 30) array_delete(chat_lines, 0, 1);
};

my_name = function() {
    if (global.net_name != "") return global.net_name;
    return (global.net_role == "host") ? "HOST" : "JOIN";
};

remote_name = function() {
    if (remote_pname != "") return remote_pname;
    return (global.net_role == "host") ? "JOIN" : "HOST";
};

chat_say = function(_t) {
    chat_add(my_name() + ": " + _t, 0);
    if (connected) {
        var _b = net_new_msg(MSG_CHAT);
        buffer_write(_b, buffer_string, _t);
        net_peer_send(_b);
    } else {
        chat_add("[sistema] todavia no hay nadie conectado", 2);
    }
};

net_close = function() {
    if (peer >= 0) network_destroy(peer);
    if (server >= 0) network_destroy(server);
    peer = -1;
    server = -1;
    connected = false;
    local_locked = false;
    remote_locked = false;
    auto_t = -1;
    global.net_role = "none";
    global.net_state = "menu";
};

start_host = function() {
    server = network_create_server(network_socket_tcp, NET_PORT, 2);
    if (server < 0) {
        server = -1;
        status = "NO SE PUDO ABRIR EL PUERTO " + string(NET_PORT);
        return;
    }
    global.net_role = "host";
    global.net_state = "waiting";
    status = "";
};

start_join = function() {
    if (string_length(ip_text) < 7) {
        status = "IP INVALIDA";
        return;
    }
    peer = network_create_socket(network_socket_tcp);
    if (peer < 0) {
        peer = -1;
        status = "ERROR DE RED";
        return;
    }
    global.net_role = "client";
    global.net_state = "connecting";
    status = "";
    network_connect_async(peer, ip_text, NET_PORT);
};
