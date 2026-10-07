// Port of Flecs example: reflection/runtime_nested_component
// G: struct member descriptors and raw ensure for runtime component ids are not
//    wrapped by the idiomatic API.
module flecs_ex_refl_runtime_nested;

import flecs;
import flecs::internal;
import std::io;

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	internal::EcsEntity point = w.component_id("Point", "Point", 8, 4);

	internal::EcsStructDesc pd = {};
	pd.entity = point;
	pd.members[0].name = "x";
	pd.members[0].type = internal::ECS_TYPE_F32;
	pd.members[1].name = "y";
	pd.members[1].type = internal::ECS_TYPE_F32;
	internal::ecs_struct_init(w.raw, &pd);

	internal::EcsEntity line = w.component_id("Line", "Line", 16, 4);

	internal::EcsStructDesc ld = {};
	ld.entity = line;
	ld.members[0].name = "start";
	ld.members[0].type = point;
	ld.members[1].name = "stop";
	ld.members[1].type = point;
	internal::ecs_struct_init(w.raw, &ld);

	Entity ent = w.entity("ent");

	internal::EcsTypeInfo* ti = internal::ecs_get_type_info(w.raw, line);
	void* ptr = internal::ecs_ensure_id(w.raw, ent.id, line, ti.size);

	internal::ecs_ptr_from_json(w.raw, line, ptr,
		"{\"start\": {\"x\": 10, \"y\": 20}, \"stop\": {\"x\": 30, \"y\": 40}}", null);

	String str = w.ptr_to_expr(line, ptr);
	io::printfn("%s", str);
	flecs::free_str(str);
}
