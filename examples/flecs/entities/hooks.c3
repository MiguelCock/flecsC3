// Port of Flecs example: entities/hooks
// G: ecs_set_hooks_id + EcsTypeHooks / EcsTypeInfo (via internal)
module flecs_ex_hooks;

import flecs;
import flecs::internal;
import std::io;
import libc;

struct Str
{
	ZString value;
}

fn void str_ctor(void* ptr, int count, internal::EcsTypeInfo* ti)
{
	(void)ti;
	io::printn("info: | Ctor");
	Str* v = (Str*)ptr;
	for (int i = 0; i < count; i++) v[i].value = null;
}

fn void str_dtor(void* ptr, int count, internal::EcsTypeInfo* ti)
{
	(void)ti;
	io::printn("info: | Dtor");
	Str* v = (Str*)ptr;
	for (int i = 0; i < count; i++)
	{
		libc::free(v[i].value);
		v[i].value = null;
	}
}

fn void str_move(void* dst_ptr, void* src_ptr, int count, internal::EcsTypeInfo* ti)
{
	(void)ti;
	io::printn("info: | Move");
	Str* dst = (Str*)dst_ptr;
	Str* src = (Str*)src_ptr;
	for (int i = 0; i < count; i++)
	{
		libc::free(dst[i].value);
		dst[i].value = src[i].value;
		src[i].value = null;
	}
}

fn void str_copy(void* dst_ptr, void* src_ptr, int count, internal::EcsTypeInfo* ti)
{
	(void)ti;
	io::printn("info: | Copy");
	Str* dst = (Str*)dst_ptr;
	Str* src = (Str*)src_ptr;
	for (int i = 0; i < count; i++)
	{
		libc::free(dst[i].value);
		dst[i].value = src[i].value ? libc::strdup(src[i].value) : null;
	}
}

fn void hook_callback(internal::EcsIter* it)
{
	World w = { .raw = it.world };
	ZString event = w.name_id(it.event);
	for (int i = 0; i < it.count; i++)
	{
		ZString e = w.name_id(it.entities[i]);
		io::printfn("info: | %s: %s", event.str_view(), e.str_view());
	}
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	internal::EcsTypeHooks hooks = {};
	hooks.ctor = &str_ctor;
	hooks.dtor = &str_dtor;
	hooks.move = &str_move;
	hooks.copy = &str_copy;
	hooks.on_add = &hook_callback;
	hooks.on_remove = &hook_callback;
	hooks.on_set = &hook_callback;
	internal::ecs_set_hooks_id(w.raw, w.comp(Str), &hooks);

	flecs::set_log_level(0);

	Entity tag = w.entity("Tag");
	Entity e = w.entity("Entity");

	io::printn("info: ecs_add(world, e, Str)");
	w.add(Str, e);

	io::printn("info: ecs_set(world, e, Str, {\"Hello World\"})");
	w.set(Str, e, { .value = libc::strdup("Hello World") });

	io::printn("info: ecs_add(world, e, Tag)");
	w.add_id(e, tag.id);

	io::printn("info: ecs_delete(world, e)");
	w.destroy(e);

	flecs::set_log_level(-1);
}
