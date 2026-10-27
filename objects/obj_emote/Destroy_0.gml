
// al cambiar de sala: parar la musica del baile y devolver la de fondo
if (music != -1) {
    audio_stop_sound(music);
    music = -1;
    audio_resume_all();
}
if (instance_exists(obj_playerMain)) obj_playerMain.hp_emote = false;
