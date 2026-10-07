// Port of Flecs example: systems/pipeline
module flecs_ex_sys_pipeline;

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

fn void move(Position[] p, Velocity[] v)
{
	foreach (i, &pos : p)
	{
		pos.x += v[i].x;
		pos.y += v[i].y;
	}
}

fn void print_position(Iter* it, Position[] p)
{
	foreach (i, &pos : p)
	{
		io::printfn("%s: {%f, %f}",
			it.name(it.raw.entities[i]).str_view(),
			pos.x, pos.y);
	}
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	// Move runs in the OnUpdate phase (the default), PrintPosition in PostUpdate.
	w.system("Move", &move);
	w.system("PrintPosition", &print_position, flecs::ECS_POST_UPDATE);

	Entity e1 = w.entity("e1");
	w.set(Position, e1, { .x = 10, .y = 20 });
	w.set(Velocity, e1, { .x = 1, .y = 2 });

	Entity e2 = w.entity("e2");
	w.set(Position, e2, { .x = 10, .y = 20 });
	w.set(Velocity, e2, { .x = 3, .y = 4 });

	w.progress(0.0);
}
