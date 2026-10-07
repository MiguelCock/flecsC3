// Systems: inferred vs explicit phase vs explicit terms.
module systems;

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

int pre_runs;
int terms_runs;
int expr_runs;

fn void move(Position[] pos, Velocity[] vel)
{
	foreach (i, &p : pos)
	{
		p.x += vel[i].x;
		p.y += vel[i].y;
	}
}

fn void pre_update(Iter* it)
{
	(void)it;
	pre_runs++;
}

fn void count_terms(Position[] pos)
{
	terms_runs += pos.len;
}

fn void count_expr(Velocity[] vel)
{
	expr_runs += vel.len;
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	Entity e = w.entity("player");
	w.set(Position, e, { .x = 0, .y = 0 });
	w.set(Velocity, e, { .x = 1, .y = 2 });

	// Query inferred from the callback parameters (default phase OnUpdate).
	w.system("Move", &move);

	// Explicit phase: runs before OnUpdate.
	w.system("PreUpdate", &pre_update, flecs::ECS_PRE_UPDATE);

	// Explicit terms: Position (inout) + Velocity (in).
	Term[] terms = {
		{ .id = w.comp(Position) },
		{ .id = w.comp(Velocity), .inout = InOut.IN },
	};
	w.system("Terms", &count_terms, 0, terms);

	// Explicit query expression.
	w.system_expr("Expr", &count_expr, "[in] Velocity");

	w.progress(1.0);

	Position* p = w.get(Position, e);
	io::printfn("position: (%.1f, %.1f)", p.x, p.y);
	io::printfn("pre=%d terms=%d expr=%d", pre_runs, terms_runs, expr_runs);
}
