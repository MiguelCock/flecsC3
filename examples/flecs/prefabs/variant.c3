// Port of Flecs example: prefabs/variant
module flecs_ex_prefab_variant;

import flecs;
import std::io;

struct Attack
{
	double value;
}

struct Defense
{
	double value;
}

struct FreightCapacity
{
	double value;
}

struct ImpulseSpeed
{
	double value;
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

	Entity ship = w.prefab("SpaceShip");
	w.set(ImpulseSpeed, ship, { .value = 50 });
	w.set(Defense, ship, { .value = 25 });

	Entity freighter = w.prefab("Freighter");
	w.add_pair(freighter, flecs::ECS_IS_A, ship.id);
	w.set(FreightCapacity, freighter, { .value = 100 });
	w.set(Defense, freighter, { .value = 50 });

	Entity mammoth = w.prefab("MammothFreighter");
	w.add_pair(mammoth, flecs::ECS_IS_A, freighter.id);
	w.set(FreightCapacity, mammoth, { .value = 500 });

	Entity frigate = w.prefab("Frigate");
	w.add_pair(frigate, flecs::ECS_IS_A, ship.id);
	w.set(Attack, frigate, { .value = 100 });
	w.set(Defense, frigate, { .value = 75 });
	w.set(ImpulseSpeed, frigate, { .value = 125 });

	Entity inst = w.instantiate(mammoth, "my_freighter");
	w.set(Position, inst, { .x = 10, .y = 20 });
	w.set(Defense, inst, { .value = 100 });

	Term[] terms = {
		{ .id = w.comp(Position) },
		{ .id = w.comp(ImpulseSpeed) },
		{ .id = w.comp(Defense) },
		{ .id = w.comp(FreightCapacity) },
	};
	Query q = w.query(terms);
	defer q.fini();
	Iter it = q.iter(&w);
	while (it.next())
	{
		Position* p = it.field(Position, 0);
		ImpulseSpeed* s = it.field(ImpulseSpeed, 1);
		Defense* d = it.field(Defense, 2);
		FreightCapacity* c = it.field(FreightCapacity, 3);
		foreach (i, ent : it.entities())
		{
			io::printfn("%s:", w.name_id(ent));
			io::printfn(" - position: %f, %f", p[i].x, p[i].y);
			io::printfn(" - impulse speed: %f", s[i].value);
			io::printfn(" - defense: %f", d[i].value);
			io::printfn(" - capacity: %f", c[i].value);
		}
	}
}
