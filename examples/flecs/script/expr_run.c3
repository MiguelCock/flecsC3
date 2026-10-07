// Port of Flecs example: script/expr_run
module flecs_ex_script_expr_run;

import flecs;
import flecs::internal;
import std::io;

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	int result = 0;
	Value result_value;
	result_value.init(internal::ECS_TYPE_I32, &result);

	if (!w.expr_run("10 + 20", &result_value))
	{
		io::printfn("expression failed to run");
		return;
	}

	io::printfn("result = %d", result);
}
