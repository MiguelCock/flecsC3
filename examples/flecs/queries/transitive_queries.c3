// Port of Flecs example: queries/transitive_queries
// U: Term.second/src variable refs ("$location"); ECS_TRANSITIVE trait; World.name
module flecs_ex_q_transitive;

import flecs;
import flecs::internal;
import std::io;

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	Entity located_in = w.entity();
	w.add_id(located_in, flecs::ECS_TRANSITIVE);

	Entity planet = w.entity("Planet");
	Entity continent = w.entity("Continent");
	Entity country = w.entity("Country");
	Entity state = w.entity("State");
	Entity city = w.entity("City");
	Entity person = w.entity("Person");

	Entity earth = w.entity("Earth");
	w.add_id(earth, planet.id);

	Entity north_america = w.entity("NorthAmerica");
	w.add_id(north_america, continent.id);
	w.add_id(north_america, w.pair(located_in.id, earth.id));

	Entity europe = w.entity("Europe");
	w.add_id(europe, continent.id);
	w.add_id(europe, w.pair(located_in.id, earth.id));

	Entity united_states = w.entity("UnitedStates");
	w.add_id(united_states, country.id);
	w.add_id(united_states, w.pair(located_in.id, north_america.id));

	Entity netherlands = w.entity("Netherlands");
	w.add_id(netherlands, country.id);
	w.add_id(netherlands, w.pair(located_in.id, europe.id));

	Entity california = w.entity("California");
	w.add_id(california, state.id);
	w.add_id(california, w.pair(located_in.id, united_states.id));

	Entity washington = w.entity("Washington");
	w.add_id(washington, state.id);
	w.add_id(washington, w.pair(located_in.id, united_states.id));

	Entity noord_holland = w.entity("NoordHolland");
	w.add_id(noord_holland, state.id);
	w.add_id(noord_holland, w.pair(located_in.id, netherlands.id));

	Entity san_francisco = w.entity("SanFrancisco");
	w.add_id(san_francisco, city.id);
	w.add_id(san_francisco, w.pair(located_in.id, california.id));

	Entity seattle = w.entity("Seattle");
	w.add_id(seattle, city.id);
	w.add_id(seattle, w.pair(located_in.id, washington.id));

	Entity amsterdam = w.entity("Amsterdam");
	w.add_id(amsterdam, city.id);
	w.add_id(amsterdam, w.pair(located_in.id, noord_holland.id));

	Entity bob = w.entity("Bob");
	w.add_id(bob, person.id);
	w.add_id(bob, w.pair(located_in.id, san_francisco.id));

	Entity alice = w.entity("Alice");
	w.add_id(alice, person.id);
	w.add_id(alice, w.pair(located_in.id, seattle.id));

	Entity job = w.entity("Job");
	w.add_id(job, person.id);
	w.add_id(job, w.pair(located_in.id, amsterdam.id));

	Term[] terms = {
		{ .id = person.id },
		{ .first.id = located_in.id, .second.name = "$location" },
		{ .first.id = country.id, .src.name = "$location" },
	};
	Query q = w.query(terms);
	defer q.fini();

	int location_var = q.find_var("location");

	Iter it = q.iter(&w);
	while (it.next())
	{
		internal::EcsEntity location = it.get_var(location_var);
		for (int i = 0; i < it.count(); i++)
		{
			io::printfn("%s lives in %s",
				w.name(it.entity_at(i)).str_view(), w.name_id(location).str_view());
		}
	}
}
