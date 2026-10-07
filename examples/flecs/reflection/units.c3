// Port of Flecs example: reflection/units
module flecs_ex_refl_units;

import flecs;
import flecs::internal;
import std::io;

struct WeatherStation
{
	double temperature;
	double pressure;
	double precipitation;
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	w.import_units();

	// struct_meta_full attaches a unit to each reflected member.
	w.struct_meta_full(WeatherStation, (MemberDesc[]){
		{ .name = "temperature", .unit = internal::ECS_CELSIUS },
		{ .name = "pressure", .unit = internal::ECS_BAR },
		{ .name = "precipitation", .unit = internal::ECS_MILLI_METERS },
	});

	Entity e = w.entity("station");
	w.set(WeatherStation, e, { .temperature = 24, .pressure = 1.2, .precipitation = 0.5 });

	WeatherStation* ptr = w.get(WeatherStation, e);
	MetaCursor cur = w.meta_cursor(WeatherStation, ptr);
	cur.push();
	for (int i = 0; i < 3; i++)
	{
		internal::EcsEntity u = cur.unit();
		internal::EcsUnit* u_data = (internal::EcsUnit*)internal::ecs_get_id(w.raw, u, internal::ECS_UNIT_TYPE);
		io::printfn("%s: %.1f %s", cur.member_name(), cur.get_float(), u_data.symbol.str_view());
		cur.next();
	}
	cur.pop();
}
