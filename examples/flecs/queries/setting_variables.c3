// Port of Flecs example: queries/setting_variables
// U: Term.src/second variable refs ("$platoon"/"$player");
//    World.path/id_str/name_id
module flecs_ex_q_setting_vars;

import flecs;
import flecs::internal;
import std::io;

const int PLAYER_COUNT = 100;
const int PLATOONS_PER_PLAYER = 3;

fn Entity entity_isa(World* w, ZString name, Entity base)
{
	Entity e = w.entity(name);
	w.add_pair(e, flecs::ECS_IS_A, base.id);
	return e;
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	Entity unit = w.entity("Unit");
	Entity combat_unit = entity_isa(&w, "CombatUnit", unit);
	Entity melee_unit = entity_isa(&w, "MeleeUnit", combat_unit);
	Entity ranged_unit = entity_isa(&w, "RangedUnit", combat_unit);
	(void)melee_unit;

	Entity warrior = entity_isa(&w, "Warrior", melee_unit);
	Entity wizard = entity_isa(&w, "Wizard", ranged_unit);
	Entity marksman = entity_isa(&w, "Marksman", ranged_unit);
	Entity builder = entity_isa(&w, "Builder", unit);
	(void)builder;

	Entity player_tag = w.entity("Player");
	Entity platoon_tag = w.entity("Platoon");

	for (int p = 0; p < PLAYER_COUNT; p++)
	{
		Entity player;
		if (p == 0)
		{
			player = w.entity("MyPlayer");
		}
		else
		{
			player = w.entity();
		}
		w.add_id(player, player_tag.id);

		for (int pl = 0; pl < PLATOONS_PER_PLAYER; pl++)
		{
			Entity platoon = w.entity();
			w.add_id(platoon, w.pair(player_tag.id, player.id));
			w.add_id(platoon, platoon_tag.id);

			Entity warrior_e = w.entity();
			w.add_id(warrior_e, warrior.id);
			w.add_id(warrior_e, w.pair(platoon_tag.id, platoon.id));

			Entity marksman_e = w.entity();
			w.add_id(marksman_e, marksman.id);
			w.add_id(marksman_e, w.pair(platoon_tag.id, platoon.id));

			Entity wizard_e = w.entity();
			w.add_id(wizard_e, wizard.id);
			w.add_id(wizard_e, w.pair(platoon_tag.id, platoon.id));
		}
	}

	Term[] terms = {
		{ .first.id = ranged_unit.id },
		{ .first.id = platoon_tag.id, .second.name = "$platoon" },
		{ .first.id = player_tag.id, .src.name = "$platoon", .second.name = "$player" },
	};
	Query q = w.query(terms);
	defer q.fini();

	int player_var = q.find_var("player");
	int platoon_var = q.find_var("platoon");

	Iter it = q.iter(&w);
	it.set_var(player_var, w.lookup("MyPlayer").id);

	while (it.next())
	{
		internal::EcsEntity player = it.get_var(player_var);
		internal::EcsEntity platoon = it.get_var(platoon_var);
		String platoon_str = w.path({ platoon });
		String class_str = w.id_str(it.field_id(0));

		for (int i = 0; i < it.count(); i++)
		{
			String unit_str = w.path(it.entity_at(i));
			io::printfn("Unit %s of class %s in platoon %s for player %s",
				unit_str, class_str, platoon_str, w.name_id(player).str_view());
			flecs::free_str(unit_str);
		}

		flecs::free_str(class_str);
		flecs::free_str(platoon_str);
	}
}
