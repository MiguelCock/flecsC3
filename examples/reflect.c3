// Reflection + JSON: register struct/enum reflection and serialize values.
module reflect;

import flecs;
import std::io;

struct Position
{
	float x;
	float y;
}

struct Info
{
	int level;
	bool active;
	String label;
}

enum Color : int
{
	RED,
	GREEN,
	BLUE,
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	w.struct_meta(Position);
	w.struct_meta(Info);
	w.enum_meta(Color);

	Entity e = w.entity("player");
	w.set(Position, e, { .x = 1.5, .y = 2.5 });
	w.set(Info, e, { .level = 3, .active = true, .label = "hello" });
	w.set(Color, e, Color.GREEN);

	String json = w.entity_to_json(e, true);
	io::printfn("%s", json);
	flecs::free_str(json);
}
