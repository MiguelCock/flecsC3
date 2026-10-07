// Port of Flecs example: prefabs/hierarchy
module flecs_ex_prefab_hierarchy;

import flecs;
import std::io;

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	Entity ship = w.prefab("SpaceShip");
	w.prefab_child(ship, "Engine");
	w.prefab_child(ship, "Cockpit");

	Entity inst = w.instantiate(ship, "my_spaceship");
	Entity inst_engine = w.lookup_child(inst, "Engine");
	Entity inst_cockpit = w.lookup_child(inst, "Cockpit");

	io::printfn("instance engine:  %s", w.path(inst_engine));
	io::printfn("instance cockpit: %s", w.path(inst_cockpit));
}
