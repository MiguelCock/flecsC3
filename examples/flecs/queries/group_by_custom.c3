// Port of Flecs example: queries/group_by_custom
// G: ecs_table_get_type (EcsType is internal) / ecs_table_str have no public
//    wrapper
// U: World.search + pair_second to find the group target; query_opts(group_by_callback)
module flecs_ex_q_group_by_custom;

import flecs;
import flecs::internal;
import std::io;

struct Position
{
	double x;
	double y;
}

fn ulong group_by_relation(internal::EcsWorld* world, internal::EcsTable* table,
	internal::EcsId id, void* ctx)
{
	(void)ctx;
	World w = { .raw = world };
	int index = w.search(table, w.pair(id, flecs::ECS_WILDCARD));
	if (index == -1)
	{
		return 0;
	}
	internal::EcsType* type = internal::ecs_table_get_type(table);
	return w.pair_second(type.array[index]);
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	Entity tag = w.entity("Tag");
	Entity group = w.entity("Group");
	Entity first = w.entity("First");
	Entity second = w.entity("Second");
	Entity third = w.entity("Third");

	Term[] terms = { { .id = w.comp(Position) } };
	QueryOptions opts = {
		.group_by = group.id,
		.group_by_callback = &group_by_relation,
	};
	Query q = w.query_opts(terms, opts);
	defer q.fini();

	Entity e1 = w.entity();
	w.add_id(e1, w.pair(group.id, third.id));
	w.set(Position, e1, { .x = 1, .y = 1 });

	Entity e2 = w.entity();
	w.add_id(e2, w.pair(group.id, second.id));
	w.set(Position, e2, { .x = 2, .y = 2 });

	Entity e3 = w.entity();
	w.add_id(e3, w.pair(group.id, first.id));
	w.set(Position, e3, { .x = 3, .y = 3 });

	Entity e4 = w.entity();
	w.add_id(e4, w.pair(group.id, third.id));
	w.set(Position, e4, { .x = 4, .y = 4 });
	w.add_id(e4, tag.id);

	Entity e5 = w.entity();
	w.add_id(e5, w.pair(group.id, second.id));
	w.set(Position, e5, { .x = 5, .y = 5 });
	w.add_id(e5, tag.id);

	Entity e6 = w.entity();
	w.add_id(e6, w.pair(group.id, first.id));
	w.set(Position, e6, { .x = 6, .y = 6 });
	w.add_id(e6, tag.id);

	Iter it = q.iter(&w);
	while (it.next())
	{
		Position* p = it.field(Position, 0);
		String table_str = internal::ecs_table_str(w.raw, it.raw.table).str_view();
		String group_str = w.path({ it.group() });

		io::printfn(" - group %s: table [%s]", group_str, table_str);

		for (int i = 0; i < it.count(); i++)
		{
			io::printfn("     {%f, %f}", p[i].x, p[i].y);
		}

		flecs::free_str(group_str);
		flecs::free_str(table_str);
		io::printfn("");
	}
}
