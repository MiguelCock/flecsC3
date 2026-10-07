// Port of Flecs example: reflection/basics_deserialize
module flecs_ex_refl_deser;

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
	Position* ptr = w.ensure(Position, ent);

	MetaCursor c = w.meta_cursor(Position, ptr);
	c.push();
	c.set_float(10);
	c.next();
	c.set_float(20);
	c.pop();

	String str = w.ptr_to_expr(w.comp(Position), ptr);
	io::printfn("%s", str);
	flecs::free_str(str);

	MetaCursor c2 = w.meta_cursor(Position, ptr);
	c2.push();
	c2.set_float(20);
	c2.next();
	c2.set_float(10);
	c2.pop();

	str = w.ptr_to_expr(w.comp(Position), ptr);
	io::printfn("%s", str);
	flecs::free_str(str);
}
