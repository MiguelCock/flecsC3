// Port of Flecs example: script/data/expressions (script file driver)
module flecs_ex_data_expressions;

import flecs;
import std::io;

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	if (!w.script_file("examples/flecs/script/data/expressions.flecs"))
	{
		io::printfn("script failed to run");
		return;
	}

	Entity e = w.lookup("e");
	String json = w.entity_to_json(e, true);
	io::printfn("%s", json);
	flecs::free_str(json);
}
