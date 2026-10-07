// Port of Flecs example: reflection/query_to_json
// G: iterator-to-JSON is not wrapped by the idiomatic API; ecs_iter_to_json is
//    used directly.
module flecs_ex_refl_query_json;

import flecs;
import flecs::internal;
import std::io;

struct Position
{
	float x;
	float y;
}

struct Velocity
{
	float x;
	float y;
}

struct Mass
{
	float value;
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	w.struct_meta(Position);
	w.struct_meta(Velocity);
	w.struct_meta(Mass);

	Entity a = w.entity("a");
	Entity b = w.entity("b");
	Entity c = w.entity("c");
	Entity d = w.entity("d");

	w.set(Position, a, { .x = 10, .y = 20 });
	w.set(Position, b, { .x = 20, .y = 30 });
	w.set(Position, c, { .x = 30, .y = 40 });
	w.set(Position, d, { .x = 40, .y = 50 });

	w.set(Velocity, a, { .x = 1, .y = 2 });
	w.set(Velocity, b, { .x = 2, .y = 3 });
	w.set(Velocity, c, { .x = 3, .y = 4 });
	w.set(Velocity, d, { .x = 4, .y = 5 });

	w.set(Mass, c, { .value = 10 });
	w.set(Mass, d, { .value = 20 });

	Query q = w.query_expr("Position, Velocity");
	defer q.fini();

	Iter it = q.iter(&w);
	String json = internal::ecs_iter_to_json(&it.raw, null).str_view();
	io::printfn("%s", json);
	flecs::free_str(json);
}
