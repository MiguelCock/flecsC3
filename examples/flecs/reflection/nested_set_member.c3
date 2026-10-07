// Port of Flecs example: reflection/nested_set_member
module flecs_ex_refl_nested_set;

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

	w.struct_meta(Line);

	Entity ent = w.entity();
	Line* ptr = w.ensure(Line, ent);

	MetaCursor c = w.meta_cursor(Line, ptr);
	c.push();
	c.member("start");
	c.push();
	c.set_float(10);
	c.next();
	c.set_float(20);
	c.pop();
	c.member("stop");
	c.push();
	c.set_float(30);
	c.next();
	c.set_float(40);
	c.pop();
	c.pop();

	String str = w.ptr_to_expr(w.comp(Line), ptr);
	io::printfn("%s", str);
	flecs::free_str(str);
}
