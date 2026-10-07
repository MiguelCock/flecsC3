// Port of Flecs example: queries/singleton
// U: World.singleton_set/get; World.name
module flecs_ex_q_singleton;

import flecs;
import std::io;

struct Gravity
{
	double value;
}

struct Velocity
{
	double x;
	double y;
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	w.add_id({ w.comp(Gravity) }, flecs::ECS_SINGLETON);
	w.singleton_set(Gravity, { .value = 9.81 });

	Entity e1 = w.entity("e1");
	Entity e2 = w.entity("e2");
	Entity e3 = w.entity("e3");

	w.set(Velocity, e1, { .x = 0, .y = 0 });
	w.set(Velocity, e2, { .x = 0, .y = 1 });
	w.set(Velocity, e3, { .x = 0, .y = 2 });

	Term[] terms = {
		{ .id = w.comp(Velocity) },
		{ .id = w.comp(Gravity) },
	};
	Query q = w.query(terms);
	defer q.fini();

	Iter it = q.iter(&w);
	while (it.next())
	{
		Velocity* v = it.field(Velocity, 0);
		Gravity* g = it.field(Gravity, 1);
		for (int i = 0; i < it.count(); i++)
		{
			v[i].y += g.value;
			io::printfn("%s velocity is {%f, %f}",
				w.name(it.entity_at(i)).str_view(), v[i].x, v[i].y);
		}
	}
}
