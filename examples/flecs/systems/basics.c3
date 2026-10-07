// Port of Flecs example: systems/basics
module flecs_ex_sys_basics;

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

fn void move(Iter* it, Position[] p, Velocity[] v)
{
	foreach (i, &pos : p)
	{
		pos.x += v[i].x;
		pos.y += v[i].y;
		io::printfn("%s: {%f, %f}",
			it.name(it.raw.entities[i]).str_view(),
			pos.x, pos.y);
	}
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	Term[] terms = {
		{ .id = w.comp(Position) },
		{ .id = w.comp(Velocity), .inout = InOut.IN },
	};
	Entity move_sys = w.system("Move", &move, 0, terms);

	Entity e1 = w.entity("e1");
	w.set(Position, e1, { .x = 10, .y = 20 });
	w.set(Velocity, e1, { .x = 1, .y = 2 });

	Entity e2 = w.entity("e2");
	w.set(Position, e2, { .x = 10, .y = 20 });
	w.set(Velocity, e2, { .x = 3, .y = 4 });

	Entity e3 = w.entity("e3");
	w.set(Position, e3, { .x = 10, .y = 20 });
	(void)e3;

	w.run_system(move_sys);
}
