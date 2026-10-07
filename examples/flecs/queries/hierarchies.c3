// Port of Flecs example: queries/hierarchies
// U: Term.src cascade traversal (ECS_CASCADE) + ECS_WITH pair; World.each;
//    World.add_pair(ECS_CHILD_OF) for parenting; World.name
module flecs_ex_q_hierarchies;

import flecs;
import std::io;

struct LocalTransform
{
	double x;
	double y;
}

struct WorldTransform
{
	double x;
	double y;
}

fn Entity child(World* w, Entity parent, ZString name)
{
	Entity e = w.entity(name);
	w.add_pair(e, flecs::ECS_CHILD_OF, parent.id);
	return e;
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	Entity local_id = { w.comp(LocalTransform) };
	Entity world_id = { w.comp(WorldTransform) };

	w.add_id(local_id, w.pair(flecs::ECS_WITH, world_id.id));

	Entity sun = w.entity("Sun");
	w.set(LocalTransform, sun, { .x = 1, .y = 1 });

	Entity mercury = child(&w, sun, "Mercury");
	w.set(LocalTransform, mercury, { .x = 1, .y = 1 });

	Entity venus = child(&w, sun, "Venus");
	w.set(LocalTransform, venus, { .x = 2, .y = 2 });

	Entity earth = child(&w, sun, "Earth");
	w.set(LocalTransform, earth, { .x = 3, .y = 3 });

	Entity moon = child(&w, earth, "Moon");
	w.set(LocalTransform, moon, { .x = 0.1, .y = 0.1 });

	Term[] terms = {
		{ .id = w.comp(LocalTransform), .inout = InOut.IN },
		{ .id = w.comp(WorldTransform), .inout = InOut.OUT },
		{
			.id = w.comp(WorldTransform),
			.inout = InOut.IN,
			.src.id = flecs::ECS_CASCADE,
			.oper = Oper.OPTIONAL,
		},
	};
	Query q = w.query(terms);
	defer q.fini();

	Iter it = q.iter(&w);
	while (it.next())
	{
		LocalTransform* p = it.field(LocalTransform, 0);
		WorldTransform* p_out = it.field(WorldTransform, 1);
		WorldTransform* p_parent = it.field(WorldTransform, 2);
		for (int i = 0; i < it.count(); i++)
		{
			p_out[i].x = p[i].x;
			p_out[i].y = p[i].y;
			if (p_parent)
			{
				p_out[i].x += p_parent.x;
				p_out[i].y += p_parent.y;
			}
		}
	}

	it = w.each(WorldTransform);
	while (it.next())
	{
		WorldTransform* p = it.field(WorldTransform, 0);
		for (int i = 0; i < it.count(); i++)
		{
			io::printfn("%s: {%f, %f}",
				w.name(it.entity_at(i)).str_view(), p[i].x, p[i].y);
		}
	}
}
