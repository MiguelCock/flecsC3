// Port of Flecs example: queries/component_inheritance
// U: World.entity + World.add_pair(ECS_IS_A, ...); World.name
module flecs_ex_q_component_inh;

import flecs;
import std::io;

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

	Entity warrior = entity_isa(&w, "Warrior", melee_unit);
	Entity wizard = entity_isa(&w, "Wizard", ranged_unit);
	Entity marksman = entity_isa(&w, "Marksman", ranged_unit);
	Entity builder = entity_isa(&w, "Builder", unit);
	(void)warrior;
	(void)builder;

	Entity warrior_1 = w.entity("warrior_1");
	w.add_id(warrior_1, warrior.id);
	Entity warrior_2 = w.entity("warrior_2");
	w.add_id(warrior_2, warrior.id);

	Entity marksman_1 = w.entity("marksman_1");
	w.add_id(marksman_1, marksman.id);
	Entity marksman_2 = w.entity("marksman_2");
	w.add_id(marksman_2, marksman.id);

	Entity wizard_1 = w.entity("wizard_1");
	w.add_id(wizard_1, wizard.id);
	Entity wizard_2 = w.entity("wizard_2");
	w.add_id(wizard_2, wizard.id);

	Entity builder_1 = w.entity("builder_1");
	w.add_id(builder_1, builder.id);
	Entity builder_2 = w.entity("builder_2");
	w.add_id(builder_2, builder.id);

	Term[] terms = { { .id = ranged_unit.id } };
	Query q = w.query(terms);
	defer q.fini();

	Iter it = q.iter(&w);
	while (it.next())
	{
		for (int i = 0; i < it.count(); i++)
		{
			io::printfn("Unit %s found", w.name(it.entity_at(i)).str_view());
		}
	}
}
