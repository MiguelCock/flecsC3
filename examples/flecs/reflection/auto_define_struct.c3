// Port of Flecs example: reflection/auto_define_struct
module flecs_ex_refl_auto_struct;

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

	Position value = { .x = 10, .y = 20 };
	String json = w.ptr_to_json(w.comp(Position), &value);
	io::printfn("%s", json);
	flecs::free_str(json);
}
