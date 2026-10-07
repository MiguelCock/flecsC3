// Port of Flecs example: reflection/basics_bitmask
// G: struct_meta re-registers a nested enum as an enum (not a bitmask), so the
//    Sandwich struct is registered directly through ecs_struct_init.
module flecs_ex_refl_bitmask;

import flecs;
import flecs::internal;
import std::io;

enum Toppings
{
	BACON,
	LETTUCE,
	TOMATO,
	CHEESE,
}

struct Sandwich
{
	Toppings toppings;
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	// Member ordinal n maps to bit 1 << n (Bacon=1, Lettuce=2, Tomato=4).
	w.bitmask_meta(Toppings);

	internal::EcsStructDesc sd = {};
	sd.entity = w.comp(Sandwich);
	sd.members[0].name = "toppings";
	sd.members[0].type = w.comp(Toppings);
	internal::ecs_struct_init(w.raw, &sd);

	Entity ent = w.entity();
	w.set(Sandwich, ent, { .toppings = (Toppings)3 });

	Sandwich* ptr = w.get(Sandwich, ent);
	String str = w.ptr_to_expr(w.comp(Sandwich), ptr);
	io::printfn("%s", str);
	flecs::free_str(str);
}
