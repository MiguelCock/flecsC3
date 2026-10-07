// Port of Flecs example: reflection/auto_define_enum
// G: struct_meta re-registers nested enums through enum_meta, which logs a
//    duplicate-constant warning for the custom names passed to enum_meta_named.
module flecs_ex_refl_auto_enum;

import flecs;
import std::io;

enum Color
{
	RED,
	BLACK,
	WHITE,
	STAINLESSSTEEL,
}

struct Car
{
	String brand;
	Color color;
	float speed;
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	// C3 uppercases enum members, so pass the display names explicitly.
	String[] names = { "Red", "Black", "White", "StainlessSteel" };
	w.enum_meta_named(Color, names);
	w.struct_meta(Car);

	Car value = { .brand = "Delorean", .color = Color.STAINLESSSTEEL, .speed = 1.21 };
	String json = w.ptr_to_json(w.comp(Car), &value);
	io::printfn("%s", json);
	flecs::free_str(json);
}
