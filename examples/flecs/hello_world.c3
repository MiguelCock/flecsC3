// Port of Flecs example: hello_world
// G: ecs_table_str (used via flecs::internal)
// U: no idiomatic Iter.table / table type-string accessor
module flecs_ex_hello_world;

import flecs;
import flecs::internal;
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
	ZString type_str = internal::ecs_table_str(it.raw.real_world, it.raw.table);
	io::printfn("Move entities with [%s]", type_str);
	flecs::free_str(type_str.str_view());

	foreach (i, &pos : p)
	{
		pos.x += v[i].x;
		pos.y += v[i].y;
	}
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	Entity eats = w.entity("Eats");
	Entity apples = w.entity("Apples");
	Entity pears = w.entity("Pears");
	(void)pears;

	Entity bob = w.entity("Bob");
	w.set(Position, bob, { .x = 0, .y = 0 });
	w.set(Velocity, bob, { .x = 1, .y = 2 });
	w.add_pair(bob, eats.id, apples.id);

	w.system("Move", &move);

	w.progress(0);
	w.progress(0);

	Position* p = w.get(Position, bob);
	io::printfn("Bob's position is {%f, %f}", p.x, p.y);
}
