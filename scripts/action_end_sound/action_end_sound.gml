/// @description (Old DnD) - end the sound
/// @param soundid sound id (numero viejo -> se traduce por nombre)
function action_end_sound(argument0) {
	var _s = legacy_sound(argument0);
	if (_s == -1) return;
	audio_stop_sound(_s);
}
