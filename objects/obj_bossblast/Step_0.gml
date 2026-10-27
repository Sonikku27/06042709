
x += dir * spd;
life--;
idx += 0.4;
if (!instance_exists(obj_boss)) { instance_destroy(); exit; }
var _ax = obj_boss.ax;
if (life <= 0 || x < _ax - 330 || x > _ax + 300 || obj_boss.phase != FP_FIGHT) { instance_destroy(); exit; }

// el host decide si la rafaga golpea a alguien
if (host) {
    var _px = [instance_exists(obj_playerMain) ? obj_playerMain.x : -99999, obj_net.remote.tx];
    var _py = [instance_exists(obj_playerMain) ? obj_playerMain.y : -99999, obj_net.remote.ty];
    for (var i = 0; i < 2; i++) {
        if (obj_boss.php[i] > 0 && !hit_done[i] && abs(_px[i] - x) < 46 && abs(_py[i] - y) < 50) {
            hit_done[i] = true;
            boss_try_hit(i, dir);
        }
    }
}
