// Port of Flecs example: relationships/relation_component
// G: ecs_get_typeid (via internal)
module flecs_ex_rel_component;

import flecs;
import flecs::internal;
import std::io;

struct Requires
{
	double amount;
}

struct Expires
{
	double timeout;
}

struct Position
{
	double x;
	double y;
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	Entity gigawatts = w.entity("Gigawatts");
	Entity must_have = w.entity("MustHave");

	// (Requires, Gigawatts)
	Entity e1 = w.entity();
	w.set_pair(Requires, e1, gigawatts.id, { .amount = 1.21 });
	Requires* r = w.get_pair(Requires, e1, gigawatts.id);
	io::printfn("requires: %.2f", r.amount);

	// (Gigawatts, Requires)
	Entity e2 = w.entity();
	w.set_pair_second(Requires, e2, gigawatts.id, { .amount = 1.21 });
	r = w.get_pair_second(Requires, e2, gigawatts.id);
	io::printfn("requires: %.2f", r.amount);

	// (Expires, Position)
	Entity e3 = w.entity();
	w.set_pair(Expires, e3, w.comp(Position), { .timeout = 0.5 });
	Expires* x = w.get_pair(Expires, e3, w.comp(Position));
	io::printfn("expires: %.1f", x.timeout);

	// Mark MustHave as a tag relationship
	w.add_id(must_have, flecs::ECS_PAIR_IS_TAG);
	w.new_pair(must_have.id, w.comp(Position));

	internal::EcsEntity type_id = internal::ecs_get_typeid(w.raw,
		w.pair(w.comp(Requires), gigawatts.id));
	String tp = w.path({ type_id });
	io::printfn("%s", tp);
	flecs::free_str(tp);

	type_id = internal::ecs_get_typeid(w.raw, w.pair(gigawatts.id, w.comp(Requires)));
	tp = w.path({ type_id });
	io::printfn("%s", tp);
	flecs::free_str(tp);

	type_id = internal::ecs_get_typeid(w.raw, w.pair(w.comp(Expires), w.comp(Position)));
	tp = w.path({ type_id });
	io::printfn("%s", tp);
	flecs::free_str(tp);

	type_id = internal::ecs_get_typeid(w.raw, w.pair(must_have.id, w.comp(Position)));
	tp = w.path({ type_id });
	io::printfn("%s", tp);
	flecs::free_str(tp);

	Term[] terms = { { .id = w.pair(w.comp(Requires), gigawatts.id) } };
	Query q = w.query(terms);
	defer q.fini();
	Iter it = q.iter(&w);
	while (it.next())
	{
		Requires* req = it.field(Requires, 0);
		foreach (i, ent : it.entities())
		{
			io::printfn("requires %.2f gigawatts", req[i].amount);
		}
	}
}
