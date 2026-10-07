// Port of Flecs example: script/data/reflection (script file driver)
module flecs_ex_data_reflection;

import flecs;
import std::io;

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	if (!w.script_file("examples/flecs/script/data/reflection.flecs"))
	{
		io::printfn("script failed to run");
		return;
	}

	Entity e = w.lookup("my_entity");
	String json = w.entity_to_json(e, true);
	io::printfn("%s", json);
	flecs::free_str(json);
}
