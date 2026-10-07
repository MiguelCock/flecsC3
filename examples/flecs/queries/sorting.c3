// Port of Flecs example: queries/sorting
// G: SystemOptions has no order_by/order_by_callback, so the sorted system is
//    created from a raw EcsSystemDesc
// U: query_opts(order_by/order_by_callback) for the sorted query; World.run_system;
//    Iter.field in the run callback
module flecs_ex_q_sorting;

import flecs;
import flecs::internal;
import std::io;

struct Position
{
	double x;
	double y;
}

fn int compare_position(internal::EcsEntity e1, void* ptr1,
	internal::EcsEntity e2, void* ptr2)
{
	(void)e1;
	(void)e2;
	Position* p1 = (Position*)ptr1;
	Position* p2 = (Position*)ptr2;
	if (p1.x < p2.x)
	{
		return -1;
	}
	if (p1.x > p2.x)
	{
		return 1;
	}
	return 0;
}

fn void print_position(internal::EcsIter* raw)
{
	Iter it = { *raw };
	Position* p = it.field(Position, 0);
	for (int i = 0; i < it.count(); i++)
	{
		io::printfn("{%.1f, %.1f}", p[i].x, p[i].y);
	}
}

fn void print_query(World* w, Query* q)
{
	Iter it = q.iter(w);
	while (it.next())
	{
		print_position(&it.raw);
	}
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	Entity position_id = { w.comp(Position) };

	Entity e = w.entity();
	w.set(Position, e, { .x = 1, .y = 0 });
	Entity tmp = w.entity();
	w.set(Position, tmp, { .x = 6, .y = 0 });
	tmp = w.entity();
	w.set(Position, tmp, { .x = 2, .y = 0 });
	tmp = w.entity();
	w.set(Position, tmp, { .x = 5, .y = 0 });
	tmp = w.entity();
	w.set(Position, tmp, { .x = 4, .y = 0 });

	internal::EcsSystemDesc sd = {};
	sd.query.terms[0].id = position_id.id;
	sd.query.order_by_callback = &compare_position;
	sd.query.order_by = position_id.id;
	sd.callback = &print_position;
	Entity sys = { internal::ecs_system_init(w.raw, &sd) };

	Term[] terms = { { .id = w.comp(Position) } };
	QueryOptions opts = {
		.order_by = w.comp(Position),
		.order_by_callback = &compare_position,
	};
	Query q = w.query_opts(terms, opts);
	defer q.fini();

	io::printfn("-- First iteration");
	print_query(&w, &q);

	w.set(Position, e, { .x = 7, .y = 0 });

	io::printfn("\n-- Second iteration");
	print_query(&w, &q);

	tmp = w.entity();
	w.set(Position, tmp, { .x = 3, .y = 0 });

	io::printfn("\n-- System iteration");
	w.run_system(sys);
}
