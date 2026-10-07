// Port of Flecs example: systems/startup_system
module flecs_ex_sys_startup_system;

import flecs;
import std::io;

fn void startup(Iter* it)
{
	io::printfn("%s",
		it.name(it.raw.system).str_view());
}

fn void update(Iter* it)
{
	io::printfn("%s",
		it.name(it.raw.system).str_view());
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	// EcsOnStart systems only run on the very first frame.
	w.system("Startup", &startup, flecs::ECS_ON_START);
	w.system("Update", &update);

	// First frame runs both Startup and Update, second frame only Update.
	w.progress(0.0);
	w.progress(0.0);
}
