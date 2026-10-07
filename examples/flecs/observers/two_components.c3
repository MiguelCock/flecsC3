// Port of Flecs example: observers/two_components
module flecs_ex_obs_two_components;

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

fn void observer(Iter* it, Position[] p, Velocity[] v)
{
	foreach (i, e : it.entities())
	{
		io::printfn("%s: %s: %s: p: {%f, %f} v: {%f, %f}",
			it.name(it.raw.event).str_view(),
			it.name(it.raw.event_id).str_view(),
			it.name(e).str_view(),
			p[i].x, p[i].y, v[i].x, v[i].y);
	}
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	w.observer("Obs", flecs::ECS_ON_SET, &observer);

	Entity e = w.entity("e");
	w.set(Position, e, { .x = 10, .y = 20 });
	w.set(Velocity, e, { .x = 1, .y = 2 });
}
