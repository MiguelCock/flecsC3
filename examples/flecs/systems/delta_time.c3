// Port of Flecs example: systems/delta_time
module flecs_ex_sys_delta_time;

import flecs;
import std::io;

fn void print_delta_time(Iter* it)
{
	// The same delta_time is passed to all systems.
	io::printfn("delta_time: %f", it.delta_time());
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	// System with no query components: runs once per ecs_progress call.
	w.system("PrintDeltaTime", &print_delta_time);

	// progress(0) measures the time since the previous frame.
	w.progress(0.0);

	// The following frames should report approximately 100ms.
	w.sleep(0.1);
	w.progress(0.0);

	w.sleep(0.1);
	w.progress(0.0);
}
