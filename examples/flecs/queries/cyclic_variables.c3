// Port of Flecs example: queries/cyclic_variables
// U: Term.src/second variable refs ("$x"/"$y"); World.name_id for resolution
module flecs_ex_q_cyclic_vars;

import flecs;
import flecs::internal;
import std::io;

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	Entity likes = w.entity("Likes");

	Entity bob = w.entity("Bob");
	Entity alice = w.entity("Alice");
	Entity john = w.entity("John");
	Entity jane = w.entity("Jane");

	w.add_id(bob, w.pair(likes.id, alice.id));
	w.add_id(alice, w.pair(likes.id, bob.id));
	w.add_id(john, w.pair(likes.id, jane.id));
	w.add_id(jane, w.pair(likes.id, john.id));
	w.add_id(bob, w.pair(likes.id, jane.id));

	Term[] terms = {
		{ .first.id = likes.id, .src.name = "$x", .second.name = "$y" },
		{ .first.id = likes.id, .src.name = "$y", .second.name = "$x" },
	};
	Query q = w.query(terms);
	defer q.fini();

	int x_var = q.find_var("x");
	int y_var = q.find_var("y");

	Iter it = q.iter(&w);
	while (it.next())
	{
		internal::EcsEntity x = it.get_var(x_var);
		internal::EcsEntity y = it.get_var(y_var);
		io::printfn("%s likes %s",
			w.name_id(x).str_view(), w.name_id(y).str_view());
	}
}
