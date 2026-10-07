// Port of Flecs example: reflection/world_ser_deser
module flecs_ex_refl_world_ser;

import flecs;
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

fn void move(Iter* it, Position[] p, Velocity[] v)
{
	for (int i = 0; i < p.len; i++)
	{
		p[i].x += v[i].x;
		p[i].y += v[i].y;
		io::printfn("%s: {%f, %f}",
			it.name(it.raw.entities[i]).str_view(),
			p[i].x, p[i].y);
	}
}

fn void import_move_module(World* w)
{
	Entity m = w.module_init("MoveModule");
	Entity prev = w.set_scope(m);
	w.struct_meta(Position);
	w.struct_meta(Velocity);
	w.system_expr("Move", &move, "Position, [in] Velocity");
	w.set_scope(prev);
}

fn void main()
{
	World wa = flecs::create();
	defer wa.fini();
	import_move_module(&wa);

	Entity ent_1 = wa.entity("ent_1");
	Entity ent_2 = wa.entity("ent_2");
	wa.set(Position, ent_1, { .x = 10, .y = 20 });
	wa.set(Position, ent_2, { .x = 30, .y = 40 });
	wa.set(Velocity, ent_1, { .x = 1, .y = -1 });
	wa.set(Velocity, ent_2, { .x = -1, .y = 1 });

	String json = wa.to_json();
	io::printfn("%s\n", json);

	World wb = flecs::create();
	defer wb.fini();
	import_move_module(&wb);

	wb.from_json(json.zstr_tcopy());

	wa.progress(0);
	io::printfn("");
	wb.progress(0);

	flecs::free_str(json);
}
