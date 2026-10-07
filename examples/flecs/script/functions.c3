// Port of Flecs example: script/functions
module flecs_ex_script_functions;

import flecs;
import flecs::internal;
import std::io;

struct Position
{
	int x;
	int y;
}

fn void sum(internal::EcsFunctionCtx* ctx, int argc, internal::EcsValue* argv, internal::EcsValue* result)
{
	(void)ctx;
	(void)argc;
	*(long*)result.ptr = *(long*)argv[0].ptr + *(long*)argv[1].ptr;
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	w.struct_meta(Position);

	internal::EcsScriptParameter[] params = {
		{ .name = "a", .type = internal::ECS_TYPE_I64 },
		{ .name = "b", .type = internal::ECS_TYPE_I64 },
	};
	w.function("sum", internal::ECS_TYPE_I64, params, &sum);

	internal::EcsScriptParameter[] mparams = {
		{ .name = "a", .type = internal::ECS_TYPE_I64 },
	};
	w.method(internal::ECS_TYPE_I64, "add", internal::ECS_TYPE_I64, mparams, &sum);

	String code =
		"e {\n"
		"  Position: { sum(10, 20), (30).add(40) }\n"
		"}\n";

	if (!w.script(code))
	{
		io::printfn("script failed to run");
		return;
	}

	Entity e = w.lookup("e");
	Position* p = w.get(Position, e);
	io::printfn("{x: %d, y: %d}", p.x, p.y);
}
