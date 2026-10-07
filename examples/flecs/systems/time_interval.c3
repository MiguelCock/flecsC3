// Port of Flecs example: systems/time_interval
//
// World.set_interval drives systems on a time interval. The C example loops
// `while (ecs_progress(...))` until quit; as a standalone smoke test this port
// bounds the loop to a fixed number of frames. Timing dependent; smoke test
// only.
module flecs_ex_sys_time_interval;

import flecs;
import std::io;

fn void tick(Iter* it)
{
	io::printfn("%s",
		it.name(it.raw.system).str_view());
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	Entity tick_sys = w.system("Tick", &tick);
	w.set_interval(tick_sys, 1.0);

	Entity fast_tick = w.system("FastTick", &tick);
	w.set_interval(fast_tick, 0.5);

	// Run the main loop at 60 FPS.
	w.set_target_fps(60);

	for (int i = 0; i < 200; i++)
	{
		(void)w.progress(0);
	}
}
