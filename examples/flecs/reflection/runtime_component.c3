// Port of Flecs example: reflection/runtime_component
// G: struct member descriptors and raw ensure for runtime component ids are not
//    wrapped by the idiomatic API.
module flecs_ex_refl_runtime;

import flecs;
import flecs::internal;
import std::io;

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	// Register a component whose type is only known at runtime (8 bytes, 4 align).
	internal::EcsEntity position = w.component_id("Position", "Position", 8, 4);

	internal::EcsStructDesc sd = {};
	sd.entity = position;
	sd.members[0].name = "x";
	sd.members[0].type = internal::ECS_TYPE_F32;
	sd.members[1].name = "y";
	sd.members[1].type = internal::ECS_TYPE_F32;
	internal::ecs_struct_init(w.raw, &sd);

	Entity ent = w.entity("ent");

	internal::EcsTypeInfo* ti = internal::ecs_get_type_info(w.raw, position);
	void* ptr = internal::ecs_ensure_id(w.raw, ent.id, position, ti.size);

	internal::ecs_ptr_from_json(w.raw, position, ptr, "{\"x\": 10, \"y\": 20}", null);

	String str = w.ptr_to_expr(position, ptr);
	io::printfn("%s", str);
	flecs::free_str(str);
}
