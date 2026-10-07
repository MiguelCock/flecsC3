// Port of Flecs example: queries/wildcards
// U: World.set_pair / pair_second; Iter.field_id; World.name/name_id
module flecs_ex_q_wildcards;

import flecs;
import flecs::internal;
import std::io;

struct Eats
{
	int amount;
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	Entity eats = { w.comp(Eats) };
	Entity apples = w.entity("Apples");
	Entity pears = w.entity("Pears");

	Term[] terms = { { .id = w.pair(eats.id, flecs::ECS_WILDCARD) } };
	Query q = w.query(terms);
	defer q.fini();

	Entity bob = w.entity("Bob");
	w.set_pair(Eats, bob, apples.id, { .amount = 10 });
	w.set_pair(Eats, bob, pears.id, { .amount = 5 });

	Entity alice = w.entity("Alice");
	w.set_pair(Eats, alice, apples.id, { .amount = 4 });

	Iter it = q.iter(&w);
	while (it.next())
	{
		Eats* eats_ptr = it.field(Eats, 0);
		internal::EcsId pair = it.field_id(0);
		internal::EcsEntity food = w.pair_second(pair);
		for (int i = 0; i < it.count(); i++)
		{
			io::printfn("%s eats %d %s",
				w.name(it.entity_at(i)).str_view(),
				eats_ptr[i].amount, w.name_id(food).str_view());
		}
	}
}
