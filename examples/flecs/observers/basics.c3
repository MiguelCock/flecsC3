// Port of Flecs example: observers/basics
module flecs_ex_obs_basics;

import flecs;
import std::io;

struct Position
{
	double x;
	double y;
}

fn void observer(Iter* it, Position[] p)
{
	EntityId event = it.raw.event;
	EntityId event_id = it.raw.event_id;
	foreach (i, e : it.entities())
	{
		if (event == flecs::ECS_ON_ADD)
		{
			io::printfn(" - OnAdd: %s: %s",
				it.name(event_id).str_view(),
				it.name(e).str_view());
		}
		else
		{
			io::printfn(" - %s: %s: %s: {%f, %f}",
				it.name(event).str_view(),
				it.name(event_id).str_view(),
				it.name(e).str_view(),
				p[i].x, p[i].y);
		}
	}
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	// The original example listens for OnAdd and OnRemove with a single
	// observer, using the public multi-event helper.
	EntityId[2] add_remove = { flecs::ECS_ON_ADD, flecs::ECS_ON_REMOVE };
	w.observer_events("AddRemove", add_remove[..], &observer);
	w.observer("Set", flecs::ECS_ON_SET, &observer);

	Entity e = w.entity("e");
	w.set(Position, e, { .x = 10, .y = 20 });
	w.remove(Position, e);
	w.remove(Position, e);
}
