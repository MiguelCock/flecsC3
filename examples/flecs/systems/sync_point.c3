// Port of Flecs example: systems/sync_point
// G: scheduling annotations are expressed with Term.inout/src; setting a
//    component by raw id still needs internal::ecs_set_id (no public raw-id
//    setter is reachable from an iterator).
module flecs_ex_sys_sync_point;

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

EntityId g_velocity;

// Writes Velocity using ecs_set, which is deferred while the system runs. The
// [out] annotation (inout OUT, src IsEntity) lets the scheduler insert a sync
// point before Move reads it.
fn void set_velocity(Iter* it)
{
	Velocity v = { .x = 1, .y = 2 };
	for (int i = 0; i < it.raw.count; i++)
	{
		internal::ecs_set_id(it.raw.world, it.raw.entities[i], g_velocity,
			(int)Velocity::size, &v);
	}
}

fn void move(Position[] p, Velocity[] v)
{
	foreach (i, &pos : p)
	{
		pos.x += v[i].x;
		pos.y += v[i].y;
	}
}

fn void print_position(Iter* it, Position[] p)
{
	foreach (i, &pos : p)
	{
		io::printfn("%s: {%f, %f}",
			it.name(it.raw.entities[i]).str_view(),
			pos.x, pos.y);
	}
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	Entity pos = { w.comp(Position) };
	Entity vel = { w.comp(Velocity) };
	g_velocity = vel.id;

	// [none] Position: match Position but do not access the value.
	// [out] Velocity(): write Velocity without matching it (src = IsEntity).
	Term[] set_terms = {
		{ .id = pos.id, .inout = InOut.IN_OUT_NONE },
		{ .id = vel.id, .inout = InOut.OUT, .src.id = flecs::ECS_IS_ENTITY },
	};
	w.system("SetVelocity", &set_velocity, 0, set_terms);

	Term[] move_terms = {
		{ .id = pos.id },
		{ .id = vel.id, .inout = InOut.IN },
	};
	w.system("Move", &move, 0, move_terms);

	w.system("PrintPosition", &print_position, flecs::ECS_POST_UPDATE);

	Entity e1 = w.entity("e1");
	w.set(Position, e1, { .x = 10, .y = 20 });
	w.set(Velocity, e1, { .x = 1, .y = 2 });

	Entity e2 = w.entity("e2");
	w.set(Position, e2, { .x = 10, .y = 20 });
	w.set(Velocity, e2, { .x = 3, .y = 4 });

	// Debug logging shows the generated schedule (including sync points).
	flecs::set_log_level(1);
	w.progress(0.0);
	flecs::set_log_level(-1);
}
