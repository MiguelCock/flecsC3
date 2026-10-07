// Port of Flecs example: entities/iterate_components
// G: ecs_type_str / ecs_get_type (via internal); ECS_PAIR flag not exported
module flecs_ex_iterate_components;

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

// Pair flag, same value as the C `ECS_PAIR` constant.
const ulong ECS_PAIR = 1UL << 63;

fn void iterate_components(World* w, Entity e)
{
	internal::EcsType* type = internal::ecs_get_type(w.raw, e.id);

	ZString type_str = internal::ecs_type_str(w.raw, type);
	io::printfn("ecs_type_str: %s\n", type_str.str_view());
	flecs::free_str(type_str.str_view());

	internal::EcsId* ids = type.array;
	int count = type.count;

	for (int i = 0; i < count; i++)
	{
		String id_str = w.id_str(ids[i]);
		io::printfn("%d: %s", i, id_str);
		flecs::free_str(id_str);
	}
	io::printn("");

	for (int i = 0; i < count; i++)
	{
		internal::EcsId id = ids[i];
		io::printf("%d: ", i);
		if ((id & ECS_PAIR) == ECS_PAIR)
		{
			internal::EcsEntity rel = w.pair_first(id);
			internal::EcsEntity tgt = w.pair_second(id);
			io::printfn("rel: %s, tgt: %s", w.name_id(rel), w.name_id(tgt));
		}
		else
		{
			internal::EcsEntity comp = id & flecs::ECS_COMPONENT_MASK;
			io::printfn("entity: %s", w.name_id(comp));
		}
	}
	io::printfn("\n");
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	Entity bob = w.entity();
	w.set(Position, bob, { .x = 10, .y = 20 });
	w.set(Velocity, bob, { .x = 1, .y = 1 });
	Entity human = w.entity("Human");
	Entity eats = w.entity("Eats");
	Entity apples = w.entity("Apples");
	w.add_id(bob, human.id);
	w.add_pair(bob, eats.id, apples.id);

	io::printfn("Bob's components:");
	iterate_components(&w, bob);

	io::printfn("Position's components:");
	iterate_components(&w, { w.comp(Position) });
}
