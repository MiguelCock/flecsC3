// Port of Flecs example: reflection/ser_opaque_string
// G: OpaqueOptions only exposes the serialize callbacks, so ecs_opaque_init is
//    used to install assign_string for deserialization.
module flecs_ex_refl_opaque_str;

import flecs;
import flecs::internal;
import std::io;
import libc;

struct OpaqueString
{
	ZString value;
}

fn int string_serialize(internal::EcsSerializer* ser, void* ptr)
{
	OpaqueString* data = (OpaqueString*)ptr;
	return ser.value(ser, internal::ECS_TYPE_STRING, &data.value);
}

fn void string_assign_string(void* ptr, ZString value)
{
	OpaqueString* data = (OpaqueString*)ptr;
	if (data.value) libc::free((void*)data.value);
	data.value = libc::strdup(value);
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	internal::EcsOpaqueDesc desc = {};
	desc.entity = w.comp(OpaqueString);
	desc.type.as_type = internal::ECS_TYPE_STRING;
	desc.type.serialize = &string_serialize;
	desc.type.assign_string = &string_assign_string;
	internal::ecs_opaque_init(w.raw, &desc);

	OpaqueString v = {};

	internal::ecs_ptr_from_json(w.raw, w.comp(OpaqueString), &v, "\"Hello World\"", null);
	io::printfn("%s", v.value.str_view());

	String json = w.ptr_to_json(w.comp(OpaqueString), &v);
	io::printfn("%s", json);
	flecs::free_str(json);

	libc::free((void*)v.value);
}
