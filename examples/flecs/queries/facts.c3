// Port of Flecs example: queries/facts
// U: Term.src/second variable refs ("$x"/"$y")
module flecs_ex_q_facts;

import flecs;
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
		{ .first.id = likes.id, .src.name = "$x", .second.name = "$x" },
	};
	Query q = w.query(terms);
	defer q.fini();

	int x_var = q.find_var("x");
	int y_var = q.find_var("y");

	Iter it = q.iter(&w);
	it.set_var(x_var, bob.id);
	it.set_var(y_var, alice.id);
	io::printfn("Are Bob and Alice friends? %s",
		it.is_true() ? "Yes" : "No");

	it = q.iter(&w);
	it.set_var(x_var, bob.id);
	it.set_var(y_var, john.id);
	io::printfn("Are Bob and John friends? %s",
		it.is_true() ? "Yes" : "No");

	it = q.iter(&w);
	it.set_var(x_var, jane.id);
	it.set_var(y_var, john.id);
	io::printfn("Are Jane and John friends? %s",
		it.is_true() ? "Yes" : "No");

	it = q.iter(&w);
	it.set_var(x_var, john.id);
	it.set_var(y_var, jane.id);
	io::printfn("Are John and Jane friends? %s",
		it.is_true() ? "Yes" : "No");
}
