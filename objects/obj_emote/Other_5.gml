
// ROOM END: GameMaker NO ejecuta el evento Destroy al cambiar de sala, asi que la musica del baile
// seguia sonando en el menu. Aca se corta y se devuelve la de fondo (mismo codigo que Destroy_0).
if (music != -1) {
    audio_stop_sound(music);
    music = -1;
    audio_resume_all();
}
if (instance_exists(obj_playerMain)) obj_playerMain.hp_emote = false;
