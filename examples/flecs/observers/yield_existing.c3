// Port of Flecs example: observers/yield_existing
module flecs_ex_obs_yield_existing;

import flecs;
import std::io;

struct Position
{
	double x;
	double y;
}

fn void observer(Iter* it, Position[] p)
{
	foreach (i, e : it.entities())
	{
		io::printfn(" - %s: %s: %s: {%f, %f}",
			it.name(it.raw.event).str_view(),
			it.name(it.raw.event_id).str_view(),
			it.name(e).str_view(),
			p[i].x, p[i].y);
	}
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	Entity e1 = w.entity("e1");
	w.set(Position, e1, { .x = 10, .y = 20 });
	Entity e2 = w.entity("e2");
	w.set(Position, e2, { .x = 20, .y = 30 });

	w.observer_existing("Obs", flecs::ECS_ON_SET, &observer);
}
