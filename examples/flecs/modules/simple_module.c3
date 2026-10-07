// Port of Flecs example: modules/simple_module
module flecs_ex_simple_module;

import flecs;
import std::io;

struct Position
{
	double x;
	double y;
}

struct Velocity
{
	double x;
	double y;
}

fn void move(Iter* it, Position[] pos, Velocity[] vel)
{
	for (int i = 0; i < pos.len; i++)
	{
		pos[i].x += vel[i].x;
		pos[i].y += vel[i].y;
	}
}

fn void print_position(Iter* it, Position[] pos)
{
	foreach (i, &p : pos)
	{
		io::printfn("p = {%f, %f} (system)", p.x, p.y);
	}
}

fn void simple_module_import(World* w)
{
	Entity m = w.module_init("SimpleModule");
	Entity prev = w.set_scope(m);

	// Components registered while scoped to the module are namespaced under it.
	w.register(Position);
	w.register(Velocity);
	w.system("Move", &move);

	w.set_scope(prev);
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	// Import module which calls the simple_module_import function.
	simple_module_import(&w);

	Entity e = w.entity();

	// The module system "Move" runs on update; components live in the
	// "simple.module" namespace.
	w.system("PrintPosition", &print_position);

	Position p = { .x = 10, .y = 20 };
	Velocity v = { .x = 1, .y = 2 };
	w.set(Position, e, p);
	w.set(Velocity, e, v);

	w.progress(0);

	Position* pp = w.get(Position, e);
	io::printfn("p = {%f, %f} (get)", pp.x, pp.y);
}
