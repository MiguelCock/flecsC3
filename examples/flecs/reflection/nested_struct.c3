// Port of Flecs example: reflection/nested_struct
module flecs_ex_refl_nested;

import flecs;
import std::io;

struct Point
{
	float x;
	float y;
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

	// struct_meta registers nested struct members recursively.
	w.struct_meta(Line);

	Entity ent = w.entity();
	w.set(Line, ent, { .start = { 10, 20 }, .stop = { 30, 40 } });

	Line* ptr = w.get(Line, ent);
	String str = w.ptr_to_expr(w.comp(Line), ptr);
	io::printfn("%s", str);
	flecs::free_str(str);
}
