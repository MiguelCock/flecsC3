// Port of Flecs example: prefabs/nested_prefabs
// G: ecs_type_str / ecs_get_type (via internal)
module flecs_ex_prefab_nested;

import flecs;
import flecs::internal;
import std::io;

struct TirePressure
{
	double value;
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	Entity wheel = w.prefab("Wheel");
	w.set(TirePressure, wheel, { .value = 32 });

	Entity car = w.prefab("Car");

	Entity fl = w.prefab_child(car, "FrontLeft");
	w.add_pair(fl, flecs::ECS_IS_A, wheel.id);
	Entity fr = w.prefab_child(car, "FrontRight");
	w.add_pair(fr, flecs::ECS_IS_A, wheel.id);
	Entity bl = w.prefab_child(car, "BackLeft");
	w.add_pair(bl, flecs::ECS_IS_A, wheel.id);
	Entity br = w.prefab_child(car, "BackRight");
	w.add_pair(br, flecs::ECS_IS_A, wheel.id);

	Entity inst = w.instantiate(car, "my_car");
	Entity inst_fl = w.lookup_child(inst, "FrontLeft");

	ZString type = internal::ecs_type_str(w.raw, internal::ecs_get_type(w.raw, inst_fl.id));
	io::printfn("type: [%s]", type.str_view());
	flecs::free_str(type.str_view());

	TirePressure* p = w.get(TirePressure, inst_fl);
	io::printfn("pressure: %f", p.value);
}
