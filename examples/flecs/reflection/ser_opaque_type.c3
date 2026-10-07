// Port of Flecs example: reflection/ser_opaque_type
// G: OpaqueOptions only exposes the serialize callbacks, so ecs_opaque_init is
//    used to install ensure_member for deserialization.
module flecs_ex_refl_opaque_type;

import flecs;
import flecs::internal;
import std::io;
import libc;

struct Sum
{
	int a;
	int b;
}

fn int sum_serialize(internal::EcsSerializer* ser, void* ptr)
{
	Sum* data = (Sum*)ptr;
	ser.member(ser, "a");
	ser.value(ser, internal::ECS_TYPE_I32, &data.a);
	ser.member(ser, "b");
	ser.value(ser, internal::ECS_TYPE_I32, &data.b);

	int result = data.a + data.b;
	ser.member(ser, "result");
	ser.value(ser, internal::ECS_TYPE_I32, &result);
	return 0;
}

fn void* sum_ensure_member(void* ptr, ZString member)
{
	Sum* data = (Sum*)ptr;
	if (libc::strcmp(member, "a") == 0) return &data.a;
	if (libc::strcmp(member, "b") == 0) return &data.b;
	return null;
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	internal::EcsStructDesc td = {};
	td.members[0].name = "a"; td.members[0].type = internal::ECS_TYPE_I32;
	td.members[1].name = "b"; td.members[1].type = internal::ECS_TYPE_I32;
	td.members[2].name = "result"; td.members[2].type = internal::ECS_TYPE_I32;
	internal::EcsEntity sum_type = internal::ecs_struct_init(w.raw, &td);

	internal::EcsOpaqueDesc desc = {};
	desc.entity = w.comp(Sum);
	desc.type.as_type = sum_type;
	desc.type.serialize = &sum_serialize;
	desc.type.ensure_member = &sum_ensure_member;
	internal::ecs_opaque_init(w.raw, &desc);

	Sum v = { .a = 10, .b = 20 };

	String json = w.ptr_to_json(w.comp(Sum), &v);
	io::printfn("%s", json);
	flecs::free_str(json);

	internal::ecs_ptr_from_json(w.raw, w.comp(Sum), &v, "{\"a\": 20, \"b\": 22}", null);

	json = w.ptr_to_json(w.comp(Sum), &v);
	io::printfn("%s", json);
	flecs::free_str(json);
}
