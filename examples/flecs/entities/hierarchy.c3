// Port of Flecs example: entities/hierarchy
// G: ecs_type_str / ecs_get_type (via internal)
module flecs_ex_entities_hierarchy;

import flecs;
import flecs::internal;
import std::io;

struct Position
{
	double x;
	double y;
}

// Create a named child of `parent` using the public scope API.
fn Entity child(World* w, Entity parent, ZString name)
{
	Entity prev = w.set_scope(parent);
	Entity e = w.entity(name);
	w.set_scope(prev);
	return e;
}

fn void iterate_tree(World* w, Entity e, Position p_parent)
{
	String path_str = w.path(e);
	ZString type_str = internal::ecs_type_str(w.raw, internal::ecs_get_type(w.raw, e.id));
	io::printfn("%s [%s]", path_str, type_str.str_view());
	flecs::free_str(type_str.str_view());
	flecs::free_str(path_str);

	Position* ptr = w.get(Position, e);
	Position p_actual = { .x = ptr.x + p_parent.x, .y = ptr.y + p_parent.y };
	io::printfn("{%f, %f}\n", p_actual.x, p_actual.y);

	Iter it = w.children(e);
	while (it.next())
	{
		foreach (i, ent : it.entities())
		{
			iterate_tree(w, { ent }, p_actual);
		}
	}
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	Entity star = w.entity("Star");
	Entity planet = w.entity("Planet");
	Entity moon_tag = w.entity("Moon");

	Entity sun = w.entity("Sun");
	w.add_id(sun, star.id);
	w.set(Position, sun, { .x = 1, .y = 1 });

	Entity mercury = child(&w, sun, "Mercury");
	w.add_id(mercury, planet.id);
	w.set(Position, mercury, { .x = 1, .y = 1 });

	Entity venus = child(&w, sun, "Venus");
	w.add_id(venus, planet.id);
	w.set(Position, venus, { .x = 2, .y = 2 });

	Entity earth = child(&w, sun, "Earth");
	w.add_id(earth, planet.id);
	w.set(Position, earth, { .x = 3, .y = 3 });

	Entity moon = child(&w, earth, "Moon");
	w.add_id(moon, moon_tag.id);
	w.set(Position, moon, { .x = 0.1, .y = 0.1 });

	io::printfn("Child of Earth? %d\n",
		w.has_pair(moon, flecs::ECS_CHILD_OF, earth.id) ? 1 : 0);

	Entity e = w.lookup("Sun.Earth.Moon");
	String path = w.path(e);
	io::printfn("Moon found: %s\n", path);
	flecs::free_str(path);

	iterate_tree(&w, sun, { .x = 0, .y = 0 });
}
