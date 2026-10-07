// Port of Flecs example: queries/iter_targets
// G: ecs_table_get_type (EcsType is internal) / ecs_id_is_pair have no public
//    wrapper; EcsTableRecord is still opaque
// U: table type scan + pair_first/pair_second + World.name/name_id
module flecs_ex_q_iter_targets;

import flecs;
import flecs::internal;
import std::io;

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	Entity eats = w.entity("Eats");
	Entity pizza = w.entity("Pizza");
	Entity salad = w.entity("Salad");

	Entity bob = w.entity("Bob");
	w.add_id(bob, w.pair(eats.id, pizza.id));
	w.add_id(bob, w.pair(eats.id, salad.id));

	Term[] terms = { { .id = w.pair(eats.id, flecs::ECS_ANY) } };
	Query q = w.query(terms);
	defer q.fini();

	Iter it = q.iter(&w);
	while (it.next())
	{
		internal::EcsType* type = internal::ecs_table_get_type(it.raw.table);
		for (int i = 0; i < it.count(); i++)
		{
			io::printfn("%s eats:", w.name(it.entity_at(i)).str_view());
			for (int t = 0; t < type.count; t++)
			{
				internal::EcsId pid = type.array[t];
				if (!internal::ecs_id_is_pair(pid))
				{
					continue;
				}
				if (w.pair_first(pid) != eats.id)
				{
					continue;
				}
				internal::EcsEntity tgt = w.pair_second(pid);
				io::printfn(" - %s", w.name_id(tgt).str_view());
			}
		}
	}
}
