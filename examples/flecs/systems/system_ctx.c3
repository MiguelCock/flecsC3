// Port of Flecs example: systems/system_ctx
module flecs_ex_sys_system_ctx;

import flecs;
import std::io;
import libc;

struct Position
{
	double x;
	double y;
}

struct Radius
{
	double value;
}

fn double sqr(double value)
{
	return value * value;
}

fn double distance_sqr(Position* p1, Position* p2)
{
	return sqr(p2.x - p1.x) + sqr(p2.y - p1.y);
}

fn void collide(Iter* it)
{
	Query* q_collide = (Query*)it.ctx();
	Position* p1 = it.field(Position, 0);
	Radius* r1 = it.field(Radius, 1);
	World w = { .raw = it.raw.world };

	foreach (i, e1 : it.entities())
	{
		// For each matching entity, iterate the context query.
		Iter qit = q_collide.iter(&w);
		while (qit.next())
		{
			Position* p2 = qit.field(Position, 0);
			Radius* r2 = qit.field(Radius, 1);
			foreach (j, e2 : qit.entities())
			{
				if (e1 == e2) continue; // don't collide with self
				if (e2 > e1) continue;  // avoid reporting each pair twice

				double d_sqr = distance_sqr(&p1[i], &p2[j]);
				double r_sqr = sqr(r1[i].value + r2[j].value);
				if (r_sqr > d_sqr)
				{
					io::printfn("%d and %d collided!", e1, e2);
				}
			}
		}
	}
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	// Query used inside the collide system to test each entity against every
	// other entity. Passed to the system as user context.
	Term[] pos_terms = {
		{ .id = w.comp(Position), .inout = InOut.IN },
		{ .id = w.comp(Radius), .inout = InOut.IN },
	};
	Query q_position = w.query(pos_terms);
	defer q_position.fini();

	Term[] collide_terms = {
		{ .id = w.comp(Position), .inout = InOut.IN },
		{ .id = w.comp(Radius), .inout = InOut.IN },
	};
	SystemOptions opts = { .ctx = (void*)&q_position, .terms = collide_terms };
	Entity collide_sys = w.system_opts("Collide", &collide, opts);

	for (int i = 0; i < 10; i++)
	{
		Entity e = w.entity();
		w.set(Position, e, {
			.x = (double)(libc::rand() % 100),
			.y = (double)(libc::rand() % 100),
		});
		w.set(Radius, e, { .value = (double)(libc::rand() % 10 + 1) });
	}

	w.run_system(collide_sys);
}
