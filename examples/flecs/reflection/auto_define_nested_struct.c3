// Port of Flecs example: reflection/auto_define_nested_struct
module flecs_ex_refl_auto_nested;

import flecs;
import std::io;

struct Point
{
	int x;
	int y;
}

struct Line
{
	Point start;
	Point stop;
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	// struct_meta recurses into the nested Point members.
	w.struct_meta(Line);

	Line value = { .start = { 1, 2 }, .stop = { 3, 4 } };
	String json = w.ptr_to_json(w.comp(Line), &value);
	io::printfn("%s", json);
	flecs::free_str(json);
}
