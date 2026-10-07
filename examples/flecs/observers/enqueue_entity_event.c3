// Port of Flecs example: observers/enqueue_entity_event
module flecs_ex_obs_enq_entity_evt;

import flecs;
import std::io;

struct Resize
{
	double width;
	double height;
}

fn void on_click(Iter* it)
{
	// The observed entity is passed as user context.
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

	// Any (_) as id indicates the event is for the entity itself, not for a
	// specific component. The context lets the callback find the widget.
	Term[] widget_src = { { .id = flecs::ECS_ANY, .src.id = widget.id } };
	w.observer_ctx("Click", click.id, &on_click, &widget, widget_src);
	w.observer_ctx("Resize", resize.id, &on_resize, &widget, widget_src);

	w.defer_begin();
	w.enqueue(click.id, widget);

	Resize r = { .width = 100, .height = 200 };
	w.enqueue_param(resize.id, widget, &r);
	io::printn("Events enqueued");
	w.defer_end();
}
