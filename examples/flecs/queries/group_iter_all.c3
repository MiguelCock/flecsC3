// Port of Flecs example: queries/group_iter_all
// G: ecs_query_get_groups + EcsMap are not exposed; groups are collected by
//    iterating the query
// U: query_opts(group_by) + World.path
module flecs_ex_q_group_iter_all;

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

	Entity asset_a = w.entity("Asset_A");
	Entity asset_b = w.entity("Asset_B");
	Entity asset_c = w.entity("Asset_C");

	Entity e1 = w.entity();
	w.add_id(e1, w.pair(flecs::ECS_IS_A, asset_a.id));
	w.set(Position, e1, { .x = 1, .y = 1 });
	Entity e2 = w.entity();
	w.add_id(e2, w.pair(flecs::ECS_IS_A, asset_a.id));
	w.set(Position, e2, { .x = 2, .y = 2 });
	Entity e3 = w.entity();
	w.add_id(e3, w.pair(flecs::ECS_IS_A, asset_b.id));
	w.set(Position, e3, { .x = 3, .y = 3 });
	Entity e4 = w.entity();
	w.add_id(e4, w.pair(flecs::ECS_IS_A, asset_c.id));
	w.set(Position, e4, { .x = 4, .y = 4 });
	Entity e5 = w.entity();
	w.add_id(e5, w.pair(flecs::ECS_IS_A, asset_c.id));
	w.set(Position, e5, { .x = 5, .y = 5 });
	Entity e6 = w.entity();
	w.add_id(e6, w.pair(flecs::ECS_IS_A, asset_c.id));
	w.set(Position, e6, { .x = 6, .y = 6 });

	Term[] terms = { { .id = w.comp(Position) } };
	QueryOptions opts = { .group_by = flecs::ECS_IS_A };
	Query q = w.query_opts(terms, opts);
	defer q.fini();

	internal::EcsEntity[64] groups;
	int group_count = 0;
	Iter scan = q.iter(&w);
	while (scan.next())
	{
		internal::EcsEntity g = scan.group();
		bool found = false;
		for (int i = 0; i < group_count; i++)
		{
			if (groups[i] == g)
			{
				found = true;
				break;
			}
		}
		if (!found)
		{
			groups[group_count] = g;
			group_count++;
		}
	}

	for (int gi = 0; gi < group_count; gi++)
	{
		String group_str = w.path({ groups[gi] });
		io::printfn("Group %s:", group_str);
		flecs::free_str(group_str);

		Iter it = q.iter(&w);
		it.set_group(groups[gi]);
		while (it.next())
		{
			Position* p = it.field(Position, 0);
			for (int i = 0; i < it.count(); i++)
			{
				String e_str = w.path(it.entity_at(i));
				io::printfn(" - %s: {%.0f, %.0f}", e_str, p[i].x, p[i].y);
				flecs::free_str(e_str);
			}
		}
	}
}
