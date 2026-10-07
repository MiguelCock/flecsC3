module quickstart;

import flecs;
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

// Systems take the component slices they use. The query is inferred from the
// parameter types; the optional leading Iter* exposes delta time etc.
fn void move(Iter* it, Position[] pos, Velocity[] vel)
{
	foreach (i, &p : pos)
	{
		p.x += vel[i].x * (float)it.delta_time();
		p.y += vel[i].y * (float)it.delta_time();
	}
}

fn void speed(Iter* it, Velocity[] vel)
{
	foreach (i, &v : vel)
	{
		*v = (Velocity){10, 10};
	}
}

fn int main()
{
	World world = flecs::create();
	defer world.fini();

	Entity e = world.entity("player");
	world.add(Position, e);
	world.set(Velocity, e, { .x = 1, .y = 2 });
	world.set(Position, e, { .x = 0, .y = 0 });

	world.system("Speed", &speed);
	world.system("Move", &move);

	world.progress(1.0);

	Position* p = world.get(Position, e);
	if (p)
	{
		io::printfn("player position: (%.1f, %.1f)", p.x, p.y);
	}

	Query q = world.query_expr("Position, Velocity");
	defer q.fini();
	Iter it = q.iter(&world);
	int count = 0;
	while (it.next())
	{
		foreach (idx, ent : it.entities())
		{
			Position* row = it.field(Position, 0);
			io::printfn("entity %d: (%.1f, %.1f)", ent, row[idx].x, row[idx].y);
			count++;
		}
	}
	io::printfn("matched %d entities", count);

	return 0;
}
