// Port of Flecs example: script/data/prefabs (script file driver)
module flecs_ex_data_prefabs;

import flecs;
import std::io;

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	if (!w.script_file("examples/flecs/script/data/prefabs.flecs"))
	{
		io::printfn("script failed to run");
		return;
	}

	Entity ship = w.lookup("my_spaceship");
	String json = w.entity_to_json(ship, true);
	io::printfn("%s", json);
	flecs::free_str(json);
}
