// Port of Flecs example: script/script_w_vars
// G: managed scripts have no variable scope entry point, so ecs_script_parse
//    and ecs_script_eval are used with an EcsScriptEvalDesc bound to ScriptVars.
module flecs_ex_script_w_vars;

import flecs;
import flecs::internal;
import std::io;

struct Position
{
	int x;
	int y;
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	w.struct_meta(Position);

	String code =
		"e {\n"
		"  Position: {$x * 10, $y * 10}\n"
		"}\n";

	ScriptVars vars = w.script_vars();
	defer vars.fini();

	internal::EcsScriptVar* x = vars.define("x", internal::ECS_TYPE_I32);
	internal::EcsScriptVar* y = vars.define("y", internal::ECS_TYPE_I32);

	internal::EcsScriptEvalDesc desc = { .vars = vars.raw };

	internal::EcsScript* script = internal::ecs_script_parse(w.raw, "My script", code.zstr_tcopy(), &desc, null);
	if (!script)
	{
		io::printfn("script failed to parse");
		return;
	}
	defer internal::ecs_script_free(script);

	*(int*)x.value.ptr = 1;
	*(int*)y.value.ptr = 2;
	if (internal::ecs_script_eval(script, &desc, null) != 0)
	{
		io::printfn("script failed to run");
		return;
	}

	Entity e = w.lookup("e");
	Position* p = w.get(Position, e);
	io::printfn("{x: %d, y: %d}", p.x, p.y);

	*(int*)x.value.ptr = 2;
	*(int*)y.value.ptr = 3;
	if (internal::ecs_script_eval(script, &desc, null) != 0)
	{
		io::printfn("script failed to run");
		return;
	}

	p = w.get(Position, e);
	io::printfn("{x: %d, y: %d}", p.x, p.y);
}
