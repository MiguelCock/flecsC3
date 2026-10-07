// Port of Flecs example: observers/propagate
module flecs_ex_obs_propagate;

import flecs;
import std::io;

struct Position
{
	double x;
	double y;
}

fn void observer(Iter* it)
{
	Position* p_self = it.field(Position, 0);
	Position* p_parent = it.field(Position, 1);
	foreach (i, e : it.entities())
	{
		io::printfn(" - %s: %s: %s: self: {%f, %f}, parent: {%f, %f}",
			it.name(it.raw.event).str_view(),
			it.name(it.raw.event_id).str_view(),
			it.name(e).str_view(),
			p_self[i].x, p_self[i].y, p_parent[i].x, p_parent[i].y);
	}
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	Entity pos = { w.comp(Position) };

	// Listen for Position from self and from the parent (traversal via ChildOf).
	Term[] terms = {
		{ .id = pos.id },
		{ .id = pos.id, .src.id = flecs::ECS_UP, .trav = flecs::ECS_CHILD_OF },
	};
	w.observer("Obs", flecs::ECS_ON_SET, &observer, terms);

	Entity p = w.entity("p");
	Entity e = w.entity("p.e");
	w.set(Position, e, { .x = 10, .y = 20 });
	w.set(Position, p, { .x = 1, .y = 2 });
}
