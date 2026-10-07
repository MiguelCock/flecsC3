// Port of Flecs example: observers/enqueue_event
module flecs_ex_obs_enqueue_event;

import flecs;
import std::io;

struct Position
{
	double x;
	double y;
}

fn void observer(Iter* it, Position[] p)
{
	(void)p;
	foreach (i, e : it.entities())
	{
		io::printfn(" - %s: %s: %s",
			it.name(it.raw.event).str_view(),
			it.name(it.raw.event_id).str_view(),
			it.name(e).str_view());
	}
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	Entity my_event = w.entity("MyEvent");
	w.observer("Obs", my_event.id, &observer);

	Entity e = w.entity("e");
	w.set(Position, e, { .x = 10, .y = 20 });

	w.defer_begin();
	EntityId[1] ids = { w.comp(Position) };
	w.enqueue_ids(my_event.id, e, ids[..]);
	io::printn("Event enqueued!");
	w.defer_end();
}
