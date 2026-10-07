// Port of Flecs example: systems/custom_phases_no_builtin
module flecs_ex_sys_phases_nobuiltin;

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

	// Three custom phases forming a standalone chain (not branching off any
	// builtin phase). The root phase has no EcsDependsOn, so it is created
	// directly; the others use World.phase with an explicit dependency.
	Entity update = w.entity("Update");
	w.add_id(update, flecs::ECS_PHASE);

	Entity physics = w.phase("Physics", update.id);
	Entity collisions = w.phase("Collisions", physics.id);

	w.system("CollisionSystem", &sys, collisions.id);
	w.system("PhysicsSystem", &sys, physics.id);
	w.system("GameSystem", &sys, update.id);

	w.progress(0);
}
