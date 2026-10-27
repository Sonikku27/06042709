// ===== Audio heredado =====
// El codigo viejo llama a los sonidos por NUMERO (action_sound(25,0), audio_play_music(3,1)).
// Ese numero dependia del orden de los recursos, y GameMaker lo reordena al abrir/guardar el
// proyecto. Aqui se traduce cada numero a su sonido REAL (por nombre), con el orden original.
// 0-13 = musicas de fondo.

function legacy_audio_init() {
    if (variable_global_exists("legacy_snd")) return;
    global.legacy_snd = [
        snd_bgmV5,
        snd_bgmTitle,
        snd_bgmSelect,
        snd_bgmHill,
        snd_bgmHide,
        snd_bgm_drowning,
        snd_bgmYCR,
        snd_bgm_mindfuckery,
        snd_bgmRobotnik,
        snd_bgmGameOver,
        snd_endgameMessage1,
        sns_bgmHidden0,
        snd_bgmHidden1,
        snd_bgmHidden2,
        snd_v5Static,
        snd_ringget,
        snd_bgmHillEnd,
        snd_enterHiddenLevel,
        snd_chaseEnd,
        snd_kefkaDemonic,
        snd_sonicAppearKnux,
        snd_staticHillEnd,
        snd_sonicLunge,
        snd_jump,
        snd_StaticBleed,
        sfx_kefka,
        snd_sonicAppear,
        snd_static,
        snd_msgAppear,
        snd_tailsDeath,
        snd_knuxCry,
        snd_roun2,
        snd_knuxPunch,
        snd_gore,
        voice_flesh,
        voice_tooslow,
        voice_souls,
        voice_round2,
        voice_foundyou,
        voice_playwithme,
        voice_eatheart,
        snd_yourenext,
        voice_diehands,
        snd_euphoriaVoice
    ];
    global.legacy_music = -1;
}

// numero viejo -> asset de sonido (o -1 si no existe)
function legacy_sound(_n) {
    legacy_audio_init();
    if (_n < 0 || _n >= array_length(global.legacy_snd)) return -1;
    return global.legacy_snd[_n];
}

// detiene todas las musicas de fondo (numeros 0 a 13)
function legacy_audio_stop_music() {
    legacy_audio_init();
    for (var i = 0; i <= 13; i++) audio_stop_sound(global.legacy_snd[i]);
    global.legacy_music = -1;
}

// reproduce una musica de fondo (reemplaza a la anterior)
function legacy_audio_play_music(_n, _loop) {
    var _s = legacy_sound(_n);
    if (_s == -1) return -1;
    legacy_audio_stop_music();
    global.legacy_music = audio_play_sound(_s, 1, _loop);
    return global.legacy_music;
}
