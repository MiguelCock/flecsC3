// Port of Flecs example: systems/sync_point_delete
module flecs_ex_sys_sync_point_delete;

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

fn void move(Position[] p, Velocity[] v)
{
	foreach (i, &pos : p)
	{
		pos.x += v[i].x;
		pos.y += v[i].y;
	}
}

// Deletes entities with p.x >= 3. The [out] *() annotation (wildcard, inout OUT,
// src IsEntity) tells the scheduler that any component may be written, forcing a
// sync point at the merge.
fn void delete_entity(Iter* it, Position[] p)
{
	World w = { .raw = it.raw.world };
	foreach (i, &pos : p)
	{
		if (pos.x >= 3)
		{
			EntityId e = it.raw.entities[i];
			io::printfn("Delete entity %s",
				it.name(e).str_view());
			w.destroy({ e });
		}
	}
}

fn void print_position(Iter* it, Position[] p)
{
	foreach (i, &pos : p)
	{
		io::printfn("%s: {%f, %f}",
			it.name(it.raw.entities[i]).str_view(),
			pos.x, pos.y);
	}
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	Entity pos = { w.comp(Position) };
	Entity vel = { w.comp(Velocity) };

	// Basic move system.
	Term[] move_terms = {
		{ .id = pos.id },
		{ .id = vel.id, .inout = InOut.IN },
	};
	w.system("Move", &move, 0, move_terms);

	Term[] delete_terms = {
		{ .id = pos.id, .inout = InOut.IN },
		{ .id = flecs::ECS_WILDCARD, .inout = InOut.OUT, .src.id = flecs::ECS_IS_ENTITY },
	};
	w.system("DeleteEntity", &delete_entity, 0, delete_terms);

	w.system("PrintPosition", &print_position, flecs::ECS_POST_UPDATE);

	Entity e1 = w.entity("e1");
	w.set(Position, e1, { .x = 0, .y = 0 });
	w.set(Velocity, e1, { .x = 1, .y = 2 });

	Entity e2 = w.entity("e2");
	w.set(Position, e2, { .x = 1, .y = 2 });
	w.set(Velocity, e2, { .x = 1, .y = 2 });

	flecs::set_log_level(1);
	while (w.progress(0.0))
	{
		if (w.count(pos.id) == 0)
		{
			break;
		}
	}
	flecs::set_log_level(-1);
}
