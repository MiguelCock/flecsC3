// Port of Flecs example: reflection/entity_type
module flecs_ex_refl_entity_type;

import flecs;
import std::io;

struct TypeWithEntity
{
	Entity e;
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	// struct_meta maps Entity members to the built-in entity meta type.
	w.struct_meta(TypeWithEntity);

	Entity foo = w.entity("Foo");
	Entity e = w.entity();
	w.set(TypeWithEntity, e, { .e = foo });

	TypeWithEntity* ptr = w.get(TypeWithEntity, e);
	String str = w.ptr_to_expr(w.comp(TypeWithEntity), ptr);
	io::printfn("%s", str);
	flecs::free_str(str);
}
