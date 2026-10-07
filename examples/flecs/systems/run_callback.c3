// Port of Flecs example: systems/run_callback
// G: run callbacks still advance the raw query iterator with
//    internal::ecs_query_next and read fields with internal::ecs_field_w_size
//    (there is no public run-callback iterator yet).
module flecs_ex_sys_run_callback;

import flecs;
import flecs::internal;
import std::io;

struct Position
{
	double x;
	double y;
}

struct Velocity
{
	double x;
	double y;
}

// A no-op callback is required by system_opts; the run callback overrides it.
fn void noop(Iter* it)
{
	(void)it;
}

// A run callback takes control of the iteration and calls ecs_query_next itself.
fn void move(internal::EcsIter* it)
{
	io::printn("Move begin");

	while (internal::ecs_query_next(it))
	{
		Position* p = (Position*)internal::ecs_field_w_size(it, (int)Position::size, 0);
		Velocity* v = (Velocity*)internal::ecs_field_w_size(it, (int)Velocity::size, 1);

		for (int i = 0; i < it.count; i++)
		{
			p[i].x += v[i].x;
			p[i].y += v[i].y;
			io::printfn("%s: {%f, %f}",
				internal::ecs_get_name(it.world, it.entities[i]).str_view(),
				p[i].x, p[i].y);
		}
	}

	io::printn("Move end");
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	Term[] terms = {
		{ .id = w.comp(Position) },
		{ .id = w.comp(Velocity), .inout = InOut.IN },
	};
	SystemOptions opts = { .run = &move, .terms = terms };
	Entity move_sys = w.system_opts("Move", &noop, opts);

	Entity e1 = w.entity("e1");
	w.set(Position, e1, { .x = 10, .y = 20 });
	w.set(Velocity, e1, { .x = 1, .y = 2 });

	Entity e2 = w.entity("e2");
	w.set(Position, e2, { .x = 10, .y = 20 });
	w.set(Velocity, e2, { .x = 3, .y = 4 });

	Entity e3 = w.entity("e3");
	w.set(Position, e3, { .x = 10, .y = 20 });
	(void)e3;

	w.run_system(move_sys);
}
