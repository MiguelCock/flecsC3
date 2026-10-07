// Port of Flecs example: queries/group_by_callbacks
// G: ecs_table_str has no public wrapper
// U: World.query_opts(group_by + on_group_create/on_group_delete) + World.path
module flecs_ex_q_group_by_cb;

import flecs;
import flecs::internal;
import std::io;
import libc;

struct Position
{
	double x;
	double y;
}

struct GroupCtx
{
	int counter;
}

int group_counter = 0;

fn void* on_group_create(internal::EcsWorld* world, ulong group_id, void* group_by_arg)
{
	(void)group_by_arg;
	World w = { .raw = world };
	io::printfn("Group %s created", w.name_id(group_id).str_view());
	GroupCtx* ctx = (GroupCtx*)libc::malloc(GroupCtx::size);
	ctx.counter = ++group_counter;
	return ctx;
}

fn void on_group_delete(internal::EcsWorld* world, ulong group_id, void* ctx,
	void* group_by_arg)
{
	(void)group_by_arg;
	World w = { .raw = world };
	io::printfn("Group %s deleted", w.name_id(group_id).str_view());
	libc::free(ctx);
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
		.on_group_create = &on_group_create,
		.on_group_delete = &on_group_delete,
	};
	Query q = w.query_opts(terms, opts);

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

	io::printfn("");

	Iter it = q.iter(&w);
	while (it.next())
	{
		Position* p = it.field(Position, 0);
		String table_str = internal::ecs_table_str(w.raw, it.raw.table).str_view();

		ulong group_id = it.group();
		String group_str = w.path({ group_id });
		GroupCtx* ctx = (GroupCtx*)q.group_ctx(group_id);

		io::printfn(" - group %s: table [%s]", group_str, table_str);
		io::printfn("   counter: %d", ctx.counter);

		for (int i = 0; i < it.count(); i++)
		{
			io::printfn("     {%f, %f}", p[i].x, p[i].y);
		}

		flecs::free_str(group_str);
		flecs::free_str(table_str);
		io::printfn("");
	}

	q.fini();
}
