// Port of Flecs example: script/data/with (script file driver)
module flecs_ex_data_with;

import flecs;
import std::io;

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	if (!w.script_file("examples/flecs/script/data/with.flecs"))
	{
		io::printfn("script failed to run");
		return;
	}

	Entity earth = w.lookup("Earth");
	String json = w.entity_to_json(earth, true);
	io::printfn("Earth: %s", json);
	flecs::free_str(json);

	Entity jupiter = w.lookup("Jupiter");
	json = w.entity_to_json(jupiter, true);
	io::printfn("Jupiter: %s", json);
	flecs::free_str(json);
}
