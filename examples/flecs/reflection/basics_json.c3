// Port of Flecs example: reflection/basics_json
module flecs_ex_refl_json;

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

	Entity ent = w.entity("ent");
	w.set(Position, ent, { .x = 10, .y = 20 });

	Position* ptr = w.get(Position, ent);
	String str = w.ptr_to_json(w.comp(Position), ptr);
	io::printfn("Position = %s", str);
	flecs::free_str(str);

	String ent_json = w.entity_to_json(ent);
	io::printfn("ent = %s", ent_json);
	flecs::free_str(ent_json);
}
