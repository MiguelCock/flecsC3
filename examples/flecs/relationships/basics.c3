// Port of Flecs example: relationships/basics
// G: ecs_type_str / ecs_get_type (via internal)
module flecs_ex_rel_basics;

import flecs;
import flecs::internal;
import std::io;

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	Entity eats = w.entity("Eats");
	Entity grows = w.entity("Grows");
	Entity apples = w.entity("Apples");
	Entity pears = w.entity("Pears");

	Entity bob = w.entity("Bob");
	w.add_pair(bob, eats.id, apples.id);
	w.add_pair(bob, eats.id, pears.id);
	w.add_pair(bob, grows.id, pears.id);

	io::printfn("Bob eats apples? %d", w.has_pair(bob, eats.id, apples.id) ? 1 : 0);
	io::printfn("Bob grows food? %d", w.has_pair_rel(bob, grows.id) ? 1 : 0);

	ZString ts = internal::ecs_type_str(w.raw, internal::ecs_get_type(w.raw, bob.id));
	io::printfn("Bob's type: [%s]", ts.str_view());
	flecs::free_str(ts.str_view());

	io::printfn("Bob eats %s", w.name(w.target(bob, eats.id, 0)));
	io::printfn("Bob also eats %s", w.name(w.target(bob, eats.id, 1)));
}
