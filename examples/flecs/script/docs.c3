// Port of Flecs example: script/data/docs (script file driver)
module flecs_ex_data_docs;

import flecs;
import std::io;

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	if (!w.script_file("examples/flecs/script/data/docs.flecs"))
	{
		io::printfn("script failed to run");
		return;
	}

	Entity earth = w.lookup("Earth");
	io::printfn("Earth name: %s", earth.name(&w));
	io::printfn("Earth brief: %s", w.brief(earth));

	Entity position = w.lookup("Position");
	io::printfn("Position brief: %s", w.brief(position));
}
