// Port of Flecs example: reflection/basics
module flecs_ex_refl_basics;

import flecs;
import std::io;

struct Position
{
	float x;
	float y;
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	w.struct_meta(Position);

	Entity ent = w.entity();
	w.set(Position, ent, { .x = 10, .y = 20 });

	Position* ptr = w.get(Position, ent);
	String str = w.ptr_to_expr(w.comp(Position), ptr);
	io::printfn("%s", str);
	flecs::free_str(str);
}
