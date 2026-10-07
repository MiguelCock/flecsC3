// Port of Flecs example: reflection/ser_opaque_vector
// G: OpaqueOptions only exposes the serialize callbacks, so ecs_opaque_init is
//    used to install count/resize/ensure_element for deserialization.
module flecs_ex_refl_opaque_vec;

import flecs;
import flecs::internal;
import std::io;
import libc;

struct IntVector
{
	usz count;
	int* array;
}

fn int intvec_serialize(internal::EcsSerializer* ser, void* ptr)
{
	IntVector* data = (IntVector*)ptr;
	for (usz i = 0; i < data.count; i++)
	{
		ser.value(ser, internal::ECS_TYPE_I32, &data.array[i]);
	}
	return 0;
}

fn usz intvec_count(void* ptr)
{
	return ((IntVector*)ptr).count;
}

fn void intvec_resize(void* ptr, usz size)
{
	IntVector* data = (IntVector*)ptr;
	if (data.count != size)
	{
		data.count = size;
		if (!data.count)
		{
			libc::free(data.array);
			data.array = null;
		}
		else
		{
			data.array = (int*)libc::realloc(data.array, size * 4);
		}
	}
}

fn void* intvec_ensure_element(void* ptr, usz index)
{
	IntVector* data = (IntVector*)ptr;
	if (data.count <= index) intvec_resize(ptr, index + 1);
	return &data.array[index];
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	internal::EcsVectorDesc vd = {};
	vd.type = internal::ECS_TYPE_I32;
	internal::EcsEntity vec_type = internal::ecs_vector_init(w.raw, &vd);

	internal::EcsOpaqueDesc desc = {};
	desc.entity = w.comp(IntVector);
	desc.type.as_type = vec_type;
	desc.type.serialize = &intvec_serialize;
	desc.type.count = &intvec_count;
	desc.type.resize = &intvec_resize;
	desc.type.ensure_element = &intvec_ensure_element;
	internal::ecs_opaque_init(w.raw, &desc);

	IntVector v = {};

	internal::ecs_ptr_from_json(w.raw, w.comp(IntVector), &v, "[10, 20, 30]", null);

	io::printf("[");
	for (usz i = 0; i < v.count; i++)
	{
		if (i) io::printf(", ");
		io::printf("%d", v.array[i]);
	}
	io::printfn("]");

	String json = w.ptr_to_json(w.comp(IntVector), &v);
	io::printfn("%s", json);
	flecs::free_str(json);

	libc::free(v.array);
}
