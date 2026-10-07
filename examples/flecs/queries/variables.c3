// Port of Flecs example: queries/variables
// U: Term.first/src variable refs ("$food"); World.name_id for names
module flecs_ex_q_variables;

import flecs;
import flecs::internal;
import std::io;

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	Entity eats = w.entity("Eats");
	Entity healthy = w.entity("Healthy");

	Entity apples = w.entity("Apples");
	Entity salad = w.entity("Salad");
	Entity burgers = w.entity("Burgers");
	Entity pizza = w.entity("Pizza");
	Entity chocolate = w.entity("Chocolate");

	w.add_id(apples, healthy.id);
	w.add_id(salad, healthy.id);

	Entity bob = w.entity("Bob");
	w.add_id(bob, w.pair(eats.id, apples.id));
	w.add_id(bob, w.pair(eats.id, burgers.id));
	w.add_id(bob, w.pair(eats.id, pizza.id));

	Entity alice = w.entity("Alice");
	w.add_id(alice, w.pair(eats.id, salad.id));
	w.add_id(alice, w.pair(eats.id, chocolate.id));
	w.add_id(alice, w.pair(eats.id, apples.id));

	Term[] terms = {
		{ .first.id = eats.id, .second.name = "$food" },
		{ .first.id = healthy.id, .src.name = "$food" },
	};
	Query q = w.query(terms);
	defer q.fini();

	int food_var = q.find_var("food");

	Iter it = q.iter(&w);
	while (it.next())
	{
		internal::EcsEntity food = it.get_var(food_var);
		for (int i = 0; i < it.count(); i++)
		{
			io::printfn("%s eats %s",
				w.name(it.entity_at(i)).str_view(), w.name_id(food).str_view());
		}
	}
}
