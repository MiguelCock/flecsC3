// Port of Flecs example: entities/basics
// G: ecs_type_str / ecs_get_type (via internal)
module flecs_ex_entities_basics;

import flecs;
import flecs::internal;
import std::io;

struct Position
{
	double x;
	double y;
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	Entity walking = w.entity("Walking");

	Entity bob = w.entity("Bob");
	w.set(Position, bob, { .x = 10, .y = 20 });
	w.add_id(bob, walking.id);

	Position* ptr = w.get(Position, bob);
	io::printfn("{%f, %f}", ptr.x, ptr.y);

	w.set(Position, bob, { .x = 20, .y = 30 });

	Entity alice = w.entity("Alice");
	w.set(Position, alice, { .x = 10, .y = 20 });
	w.add_id(alice, walking.id);

	ZString str = internal::ecs_type_str(w.raw, internal::ecs_get_type(w.raw, alice.id));
	io::printfn("[%s]", str.str_view());
	flecs::free_str(str.str_view());

	w.remove_id(alice, walking.id);

	Iter it = w.each(Position);
	while (it.next())
	{
		Position* p = it.field(Position, 0);
		foreach (i, ent : it.entities())
		{
			io::printfn("%s: {%f, %f}", w.name_id(ent), p[i].x, p[i].y);
		}
	}
}
