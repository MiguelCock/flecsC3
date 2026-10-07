// Port of Flecs example: reflection/basics_enum
// G: struct_meta re-registers nested enums through enum_meta, which logs a
//    duplicate-constant warning for the custom names passed to enum_meta_named.
module flecs_ex_refl_enum;

import flecs;
import std::io;

enum Color
{
	RED,
	GREEN,
	BLUE,
}

struct TypeWithEnum
{
	Color color;
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	// C3 uppercases enum members, so pass the display names explicitly.
	String[] names = { "Red", "Green", "Blue" };
	w.enum_meta_named(Color, names);
	w.struct_meta(TypeWithEnum);

	Entity ent = w.entity();
	w.set(TypeWithEnum, ent, { .color = Color.GREEN });

	TypeWithEnum* ptr = w.get(TypeWithEnum, ent);
	String str = w.ptr_to_expr(w.comp(TypeWithEnum), ptr);
	io::printfn("%s", str);
	flecs::free_str(str);
}
