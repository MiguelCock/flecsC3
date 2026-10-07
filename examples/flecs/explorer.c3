// Port of Flecs example: explorer
// G: unit globals (ECS_KILO_GRAMS) live in flecs::internal.
//
// NOTE: the C example enables the REST app loop and imports FlecsStats. The
// explorer is run here with a bounded app loop (app_run(1)) so it exits. The
// REST server is only described, not started, and stats collection is skipped.
module flecs_ex_explorer;

import flecs;
import flecs::internal;
import std::io;

struct Mass
{
	double value;
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

	w.import_units();

	// Mass component with a unit annotation (kilograms).
	w.struct_meta_full(Mass, (MemberDesc[]){
		{ .name = "value", .unit = internal::ECS_KILO_GRAMS },
	});

	// Simple hierarchy.
	Entity sun = w.entity("Sun");
	w.set(Mass, sun, { .value = 1.988500e31 });

	Entity earth = child(&w, sun, "Earth");
	w.set(Mass, earth, { .value = 5.9722e24 });

	Entity moon = child(&w, earth, "Moon");
	w.set(Mass, moon, { .value = 7.34767309e22 });

	io::printfn("Sun/Mass   = %f", w.get(Mass, sun).value);
	io::printfn("Earth/Mass = %f", w.get(Mass, earth).value);
	io::printfn("Moon/Mass  = %f", w.get(Mass, moon).value);

	io::printfn("REST app loop bounded to 1 frame (would serve :27750 in the C example)");
	w.app_run(1);
}
