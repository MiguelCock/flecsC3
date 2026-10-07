// Port of Flecs example: queries/change_tracking
// G: ecs_table_str has no public wrapper
// U: Term.src traversal + query_opts(ECS_QUERY_DETECT_CHANGES) + Query.changed
module flecs_ex_q_change_tracking;

import flecs;
import flecs::internal;
import std::io;

struct Dirty
{
	bool value;
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

	Entity dirty_id = { w.comp(Dirty) };

	w.add_id(dirty_id, w.pair(flecs::ECS_ON_INSTANTIATE, flecs::ECS_INHERIT));

	Term[] read_terms = { { .id = w.comp(Position), .inout = InOut.IN } };
	QueryOptions read_opts = { .flags = flecs::ECS_QUERY_DETECT_CHANGES };
	Query q_read = w.query_opts(read_terms, read_opts);
	defer q_read.fini();

	Term[] write_terms = {
		{
			.id = w.comp(Dirty),
			.inout = InOut.IN,
			.src.id = flecs::ECS_UP,
			.trav = flecs::ECS_IS_A,
		},
		{ .id = w.comp(Position) },
	};
	Query q_write = w.query(write_terms);
	defer q_write.fini();

	Entity p1 = w.prefab("p1");
	w.set(Dirty, p1, { .value = false });

	Entity p2 = w.prefab("p2");
	w.set(Dirty, p2, { .value = true });

	Entity e1 = w.entity("e1");
	w.add_id(e1, w.pair(flecs::ECS_IS_A, p1.id));
	w.set(Position, e1, { .x = 10, .y = 20 });

	Entity e2 = w.entity("e2");
	w.add_id(e2, w.pair(flecs::ECS_IS_A, p1.id));
	w.set(Position, e2, { .x = 30, .y = 40 });

	Entity e3 = w.entity("e3");
	w.add_id(e3, w.pair(flecs::ECS_IS_A, p2.id));
	w.set(Position, e3, { .x = 50, .y = 60 });

	Entity e4 = w.entity("e4");
	w.add_id(e4, w.pair(flecs::ECS_IS_A, p2.id));
	w.set(Position, e4, { .x = 70, .y = 80 });

	io::printfn("q_read changed: %d", q_read.changed() ? 1 : 0);

	Iter it = q_read.iter(&w);
	while (it.next())
	{
		ZString table_str = internal::ecs_table_str(w.raw, it.raw.table);
		io::printfn("it.changed for table [%s]: %d",
			table_str.str_view(), it.changed() ? 1 : 0);
		flecs::free_str(table_str.str_view());
	}

	io::printfn("q_read changed: %d\n", q_read.changed() ? 1 : 0);

	it = q_write.iter(&w);
	while (it.next())
	{
		Dirty* dirty = it.field(Dirty, 0);

		ZString table_str = internal::ecs_table_str(w.raw, it.raw.table);
		io::printfn("iterate table [%s]", table_str.str_view());
		flecs::free_str(table_str.str_view());

		if (!dirty.value)
		{
			it.skip();
			table_str = internal::ecs_table_str(w.raw, it.raw.table);
			io::printfn("it.skip for table [%s]", table_str.str_view());
			flecs::free_str(table_str.str_view());
			continue;
		}

		Position* p = it.field(Position, 1);
		for (int i = 0; i < it.count(); i++)
		{
			p[i].x++;
			p[i].y++;
		}
	}

	io::printfn("\nq_read changed: %d", q_read.changed() ? 1 : 0);

	it = q_read.iter(&w);
	while (it.next())
	{
		ZString table_str = internal::ecs_table_str(w.raw, it.raw.table);
		io::printfn("it.changed for table [%s]: %d",
			table_str.str_view(), it.changed() ? 1 : 0);
		flecs::free_str(table_str.str_view());
	}
}
