/// @description (Old DnD) - play sound
/// @param index sound index (numero viejo -> se traduce por nombre)
/// @param loop true if playing a loop
function action_sound(argument0, argument1) {
	var _s = legacy_sound(argument0);
	if (_s == -1) return;
	// como en GM8: un sonido que ya suena se reinicia, no se apila
	audio_stop_sound(_s);
	audio_play_sound(_s, 1, argument1);
}
