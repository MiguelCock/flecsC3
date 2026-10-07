// Port of Flecs example: systems/mutate_entity
module flecs_ex_sys_mutate_entity;

import flecs;
import std::io;

struct Timeout
{
	double value;
}

// System that deletes an entity after a timeout expires.
fn void expire(Iter* it, Timeout[] t)
{
	World w = { .raw = it.raw.world };
	foreach (i, &to : t)
	{
		to.value -= it.delta_time();
		if (to.value <= 0)
		{
			EntityId raw = it.raw.entities[i];
			// Delete through the world: mutations are deferred.
			w.destroy({ raw });
			io::printfn("Expire: %s deleted!",
				w.name_id(raw).str_view());
		}
	}
}

// System that prints remaining expiry time.
fn void print_expire(Iter* it, Timeout[] t)
{
	foreach (i, &to : t)
	{
		io::printfn("PrintExpire: %s has %.2f seconds left",
			it.name(it.raw.entities[i]).str_view(),
			to.value);
	}
}

// Observer that triggers when the component is actually removed.
fn void expired(Iter* it)
{
	foreach (i, e : it.entities())
	{
		io::printfn("Expired: %s actually deleted",
			it.name(e).str_view());
	}
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	w.system("Expire", &expire);
	w.system("PrintExpire", &print_expire);

	Term[] obs_terms = { { .id = w.comp(Timeout) } };
	w.observer("Expired", flecs::ECS_ON_REMOVE, &expired, obs_terms);

	Entity e = w.entity("MyEntity");
	w.set(Timeout, e, { .value = 3.0 });

	w.set_target_fps(1);

	while (w.progress(0))
	{
		if (!e.is_alive(&w))
		{
			break;
		}
		io::printn("Tick...");
	}
}
