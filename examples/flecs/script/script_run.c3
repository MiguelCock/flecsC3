// Port of Flecs example: script/script_run
module flecs_ex_script_run;

import flecs;
import std::io;

fn void print_children(World* w, Entity e)
{
	Iter it = w.children(e);
	while (it.next())
	{
		foreach (i, child : it.entities())
		{
			io::printfn(" - %s", w.name_id(child));
		}
	}
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	String script =
		"Sun {\n"
		"  Mercury {}\n"
		"  Venus {}\n"
		"  Earth {}\n"
		"  Mars {}\n"
		"  Jupiter {}\n"
		"  Saturn {}\n"
		"  Neptune {}\n"
		"  Uranus {}\n"
		"}\n";

	if (!w.script(script))
	{
		io::printfn("script failed to run");
	}

	Entity sun = w.lookup("Sun");
	print_children(&w, sun);
}
