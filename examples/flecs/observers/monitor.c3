// Port of Flecs example: observers/monitor
module flecs_ex_obs_monitor;

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
	(void)p;
	(void)v;
	foreach (i, e : it.entities())
	{
		if (it.raw.event == flecs::ECS_ON_ADD)
		{
			io::printfn(" - Enter: %s: %s",
				it.name(it.raw.event_id).str_view(),
				it.name(e).str_view());
		}
		else if (it.raw.event == flecs::ECS_ON_REMOVE)
		{
			io::printfn(" - Leave: %s: %s",
				it.name(it.raw.event_id).str_view(),
				it.name(e).str_view());
		}
	}
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	w.observer("Mon", flecs::ECS_MONITOR, &observer);

	Entity e = w.entity("e");
	w.set(Position, e, { .x = 10, .y = 20 });
	w.set(Velocity, e, { .x = 1, .y = 2 });
	w.remove(Position, e);
}
