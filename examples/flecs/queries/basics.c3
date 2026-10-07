// Port of Flecs example: queries/basics
// U: World.query(Term[]) + Iter.field/entity_at accessors; World.name
module flecs_ex_q_basics;

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

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	Term[] terms = {
		{ .id = w.comp(Position) },
		{ .id = w.comp(Velocity), .inout = InOut.IN },
	};
	Query q = w.query(terms);
	defer q.fini();

	Entity e1 = w.entity("e1");
	w.set(Position, e1, { .x = 10, .y = 20 });
	w.set(Velocity, e1, { .x = 1, .y = 2 });

	Entity e2 = w.entity("e2");
	w.set(Position, e2, { .x = 10, .y = 20 });
	w.set(Velocity, e2, { .x = 3, .y = 4 });

	Entity e3 = w.entity("e3");
	w.set(Position, e3, { .x = 10, .y = 20 });

	Iter it = q.iter(&w);
	while (it.next())
	{
		Position* p = it.field(Position, 0);
		Velocity* v = it.field(Velocity, 1);
		for (int i = 0; i < it.count(); i++)
		{
			p[i].x += v[i].x;
			p[i].y += v[i].y;
			io::printfn("%s: {%f, %f}",
				w.name(it.entity_at(i)).str_view(), p[i].x, p[i].y);
		}
	}
}
