// Port of Flecs example: prefabs/override
// G: ecs_type_str / ecs_get_type (via internal)
module flecs_ex_prefab_override;

import flecs;
import flecs::internal;
import std::io;

struct Attack
{
	double value;
}

struct Defense
{
	double value;
}

struct Damage
{
	double value;
}

fn void show_type(World* w, Entity e)
{
	ZString type = internal::ecs_type_str(w.raw, internal::ecs_get_type(w.raw, e.id));
	io::printfn("instance type = [%s]", type.str_view());
	flecs::free_str(type.str_view());
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	w.add_pair({ w.comp(Attack) }, flecs::ECS_ON_INSTANTIATE, flecs::ECS_INHERIT);
	w.add_pair({ w.comp(Defense) }, flecs::ECS_ON_INSTANTIATE, flecs::ECS_INHERIT);

	Entity ship = w.prefab("SpaceShip");
	w.set(Attack, ship, { .value = 75 });
	w.set(Defense, ship, { .value = 100 });
	w.set(Damage, ship, { .value = 50 });

	Entity inst = w.instantiate(ship, "my_instance");
	show_type(&w, inst);

	w.add(Attack, inst);
	show_type(&w, inst);

	Attack* a = w.get(Attack, inst);
	Defense* d = w.get(Defense, inst);
	Damage* dm = w.get(Damage, inst);
	io::printfn("attack: %f", a.value);
	io::printfn("defense: %f", d.value);
	io::printfn("damage: %f", dm.value);
}
