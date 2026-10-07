// Port of Flecs example: script/expr_w_vars
// G: World.expr_parse/expr_eval do not accept a variable scope, so the raw
//    expression API is used with an EcsExprEvalDesc bound to ScriptVars.
module flecs_ex_script_expr_w_vars;

import flecs;
import flecs::internal;
import std::io;

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	ScriptVars vars = w.script_vars();
	defer vars.fini();

	internal::EcsScriptVar* x = vars.define("x", internal::ECS_TYPE_I32);
	internal::EcsScriptVar* y = vars.define("y", internal::ECS_TYPE_I32);

	*(int*)x.value.ptr = 10;
	*(int*)y.value.ptr = 20;

	int result = 0;
	Value result_value;
	result_value.init(internal::ECS_TYPE_I32, &result);

	internal::EcsExprEvalDesc desc = { .vars = vars.raw };

	internal::EcsScript* s = internal::ecs_expr_parse(w.raw, "$x + $y", &desc);
	defer internal::ecs_script_free(s);

	if (!s)
	{
		io::printfn("failed to parse expression");
		return;
	}

	if (internal::ecs_expr_eval(s, &result_value.raw, &desc))
	{
		io::printfn("failed to evaluate expression");
		return;
	}
	io::printfn("result = %d", result);

	*(int*)y.value.ptr = 30;
	if (internal::ecs_expr_eval(s, &result_value.raw, &desc))
	{
		io::printfn("failed to evaluate expression");
		return;
	}
	io::printfn("result = %d", result);
}
