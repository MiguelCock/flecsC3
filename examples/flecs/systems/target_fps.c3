// Port of Flecs example: systems/target_fps
// World.set_target_fps makes ecs_progress insert sleeps to hit the target.
// Timing dependent; smoke test only.
module flecs_ex_sys_target_fps;

import flecs;
import std::io;

fn void print_delta_time(Iter* it)
{
	io::printfn("delta_time: %f", it.delta_time());
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	w.system("PrintDeltaTime", &print_delta_time);

	w.set_target_fps(1);

	for (int i = 0; i < 5; i++)
	{
		w.progress(0);
	}
}
