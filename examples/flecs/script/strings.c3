// Port of Flecs example: script/data/strings (script file driver)
module flecs_ex_data_strings;

import flecs;
import std::io;

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	if (!w.script_file("examples/flecs/script/data/strings.flecs"))
	{
		io::printfn("script failed to run");
		return;
	}

	Entity pipeline = w.lookup("my_pipeline");
	String json = w.entity_to_json(pipeline, true);
	io::printfn("%s", json);
	flecs::free_str(json);
}
