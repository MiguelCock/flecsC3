// Port of Flecs example: observers/entity_event
module flecs_ex_obs_entity_event;

import flecs;
import std::io;

struct Resize
{
	double width;
	double height;
}

fn void on_click(Iter* it)
{
	Entity* widget = (Entity*)it.ctx();
	World w = { .raw = it.raw.world };
	String path = w.path(*widget);
	io::printfn("clicked on %s!", path);
	flecs::free_str(path);
}

fn void on_resize(Iter* it)
{
	Entity* widget = (Entity*)it.ctx();
	Resize* p = (Resize*)it.raw.param;
	World w = { .raw = it.raw.world };
	String path = w.path(*widget);
	io::printfn("resized %s to {%.0f, %.0f}!", path, p.width, p.height);
	flecs::free_str(path);
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	Entity click = w.entity("Click");
	Entity resize = { w.comp(Resize) };
	Entity widget = w.entity("MyWidget");

	// _ (EcsAny) indicates the event is for the entity itself, not a component.
	Term[] widget_src = { { .id = flecs::ECS_ANY, .src.id = widget.id } };
	w.observer_ctx("Click", click.id, &on_click, &widget, widget_src);
	w.observer_ctx("Resize", resize.id, &on_resize, &widget, widget_src);

	w.emit(click.id, widget);

	Resize r = { .width = 100, .height = 200 };
	w.emit_param(resize.id, widget, &r);
}
