// Port of Flecs example: script/script_managed
module flecs_ex_script_managed;

import flecs;
import std::io;

fn void print_planets(World* w)
{
	Entity sun = w.lookup("Sun");
	Iter it = w.children(sun);
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

	String code =
		"Sun {\n"
		"  Mercury {}\n"
		"  Venus {}\n"
		"  Earth {}\n"
		"  Mars {}\n"
		"  Jupiter {}\n"
		"  Saturn {}\n"
		"  Neptune {}\n"
		"  Uranus {}\n"
		"  Pluto {}\n"
		"}\n";

	Entity script = w.script_init("My script", code);
	if (!script.id)
	{
		io::printfn("script failed to run");
	}

	io::printfn("Before updating script:");
	print_planets(&w);

	Entity instance = { 0 };
	w.script_update(script, instance,
		"Sun {\n"
		"  Mercury {}\n"
		"  Venus {}\n"
		"  Earth {}\n"
		"  Mars {}\n"
		"  Jupiter {}\n"
		"  Saturn {}\n"
		"  Neptune {}\n"
		"  Uranus {}\n"
		"}\n");

	io::printfn("\nAfter updating script:");
	print_planets(&w);
}
