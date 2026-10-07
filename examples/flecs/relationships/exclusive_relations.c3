// Port of Flecs example: relationships/exclusive_relations
module flecs_ex_rel_exclusive;

import flecs;
import std::io;

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	Entity platoon = w.entity("Platoon");
	w.add_id(platoon, flecs::ECS_EXCLUSIVE);

	Entity platoon_1 = w.entity();
	Entity platoon_2 = w.entity();
	Entity unit = w.entity();

	w.add_pair(unit, platoon.id, platoon_1.id);

	io::printfn("Unit in platoon 1: %s",
		w.has_pair(unit, platoon.id, platoon_1.id) ? "true" : "false");
	io::printfn("Unit in platoon 2: %s\n",
		w.has_pair(unit, platoon.id, platoon_2.id) ? "true" : "false");

	w.add_pair(unit, platoon.id, platoon_2.id);

	io::printfn("Unit in platoon 1: %s",
		w.has_pair(unit, platoon.id, platoon_1.id) ? "true" : "false");
	io::printfn("Unit in platoon 2: %s",
		w.has_pair(unit, platoon.id, platoon_2.id) ? "true" : "false");
}
