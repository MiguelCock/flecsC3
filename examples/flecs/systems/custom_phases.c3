// Port of Flecs example: systems/custom_phases
module flecs_ex_sys_custom_phases;

import flecs;
import std::io;

fn void sys(Iter* it)
{
	io::printfn("system %s",
		it.name(it.raw.system).str_view());
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	// Two custom phases branching off EcsOnUpdate. World.phase defaults the
	// dependency to EcsOnUpdate.
	Entity physics = w.phase("Physics");
	Entity collisions = w.phase("Collisions", physics.id);

	w.system("CollisionSystem", &sys, collisions.id);
	w.system("PhysicsSystem", &sys, physics.id);
	w.system("GameSystem", &sys);

	w.progress(0);
}
