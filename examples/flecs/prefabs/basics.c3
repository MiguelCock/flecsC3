// Port of Flecs example: prefabs/basics
module flecs_ex_prefab_basics;

import flecs;
import std::io;

struct Defense
{
	double value;
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	w.add_pair({ w.comp(Defense) }, flecs::ECS_ON_INSTANTIATE, flecs::ECS_INHERIT);

	Entity ship = w.prefab("SpaceShip");
	w.set(Defense, ship, { .value = 50 });

	Entity inst = w.instantiate(ship, "my_spaceship");
	Defense* d = w.get(Defense, inst);
	io::printfn("defense: %f", d.value);

	w.set(Defense, ship, { .value = 100 });
	io::printfn("defense after set: %f", d.value);

	Term[] terms = { { .id = w.comp(Defense) } };
	Query q = w.query(terms);
	defer q.fini();
	Iter it = q.iter(&w);
	while (it.next())
	{
		Defense* dd = it.field(Defense, 0);
		foreach (i, ent : it.entities())
		{
			io::printfn("%s: defense: %f", w.name_id(ent), dd[i].value);
		}
	}
}
