// Port of Flecs example: queries/group_by
// G: ecs_table_str has no public wrapper
// U: World.query_opts(group_by) + World.path
module flecs_ex_q_group_by;

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

	Entity tag = w.entity("Tag");
	Entity group = w.entity("Group");
	Entity first = w.entity("First");
	Entity second = w.entity("Second");
	Entity third = w.entity("Third");

	Term[] terms = { { .id = w.comp(Position) } };
	QueryOptions opts = { .group_by = group.id };
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
