// Term-based query construction.
module queries;

import flecs;
import std::io;

struct Position
{
	float x;
	float y;
}

struct Velocity
{
	float x;
	float y;
}

struct Frozen { int marker; }

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	// --- Position AND Velocity([in]) -------------------------------------
	Term[] moving = {
		{ .id = w.comp(Position) },
		{ .id = w.comp(Velocity), .inout = InOut.IN },
	};
	Query q = w.query(moving);
	defer q.fini();

	Entity e = w.entity("mover");
	w.set(Position, e, { .x = 1, .y = 2 });
	w.set(Velocity, e, { .x = 3, .y = 4 });

	int moving_count = 0;
	Iter it = q.iter(&w);
	while (it.next()) moving_count += it.count();
	io::printfn("moving entities: %d", moving_count);

	// --- Position AND NOT Frozen AND OPTIONAL ChildOf(parent) -------------
	Entity parent = w.entity("parent");
	Term[] not_frozen = {
		{ .id = w.comp(Position) },
		{ .id = w.comp(Frozen), .oper = Oper.NOT },
		{ .id = w.pair(flecs::ECS_CHILD_OF, parent.id), .oper = Oper.OPTIONAL },
	};
	Query q2 = w.query(not_frozen);
	defer q2.fini();

	int count2 = 0;
	Iter it2 = q2.iter(&w);
	while (it2.next()) count2 += it2.count();
	io::printfn("not frozen: %d", count2);

	// --- Or -----------------------------------------------------------------
	Term[] pos_or_vel = {
		{ .id = w.comp(Position), .oper = Oper.OR },
		{ .id = w.comp(Velocity) },
	};
	Query q3 = w.query(pos_or_vel);
	defer q3.fini();
	int count3 = 0;
	Iter it3 = q3.iter(&w);
	while (it3.next()) count3 += it3.count();
	io::printfn("pos or vel: %d", count3);

	// --- String expression form --------------------------------------------
	Query q4 = w.query_expr("Position, [in] Velocity");
	defer q4.fini();
	int count4 = 0;
	Iter it4 = q4.iter(&w);
	while (it4.next()) count4 += it4.count();
	io::printfn("query_expr: %d", count4);
}
