// Port of Flecs example: entities/fwd_declare_component
// C3 has no C translation-unit issue: module-scope types/ids are reachable from
// any function, so no forward declaration is needed. World.comp(T) replaces
// ECS_COMPONENT_DECLARE/DEFINE + ecs_id(T).
module flecs_ex_fwd_declare;

import flecs;
import std::io;

struct Position
{
	double x;
	double y;
}

fn Entity create_npc(World* w)
{
	Entity result = w.entity();
	w.set(Position, result, { .x = 10, .y = 20 });
	w.add_id(result, w.entity("Wizard").id);
	return result;
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	Entity platoon_1 = w.entity();
	(void)platoon_1;

	Entity e = create_npc(&w);
	Position* p = w.get(Position, e);
	io::printfn("{%f, %f}", p.x, p.y);

	io::printfn("Id of Position is %d", (long)w.comp(Position));
}
