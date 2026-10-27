function startup() {
	// mitigacion grafica: evita crear la textura depth-stencil de la superficie de aplicacion
	// (CreateTexture2D / CreateDepthStencilView / CreateShaderResourceView fallan en GPUs basicas o VMs)
	surface_depth_disable(true);
	application_surface_enable(false);
	show_debug_message("**********************************.");
	show_debug_message("Sonic.EXE by MY5TCrimson. Initializing...");
	global.playerscore = 0;
	global.rings = 0;
	global.character = "tails";
	global.hudState = "normal";
	global.hudV5Invert = 0;
	global.tailsHiddenClear = 0;
	global.knuxHiddenClear = 0;
	global.robotnikHiddenClear = 0;
	// --- multijugador ---
	global.net_role = "none";      // none / host / client
	global.net_state = "menu";     // menu / ip / waiting / connecting / pick / ingame
	global.net_skin = "sonic";     // mi personaje: sonic / amy
	global.net_skin_on = false;    // true cuando ya elegi personaje
	global.fight_on = false;
	instance_create_depth(0, 0, -16000, obj_net);
	show_debug_message("Initialized. Starting the Nightmare.");
	show_debug_message("**********************************.");
	room_goto_next();
}
