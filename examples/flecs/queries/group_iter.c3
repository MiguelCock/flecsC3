// Port of Flecs example: queries/group_iter
// G: ecs_table_get_type / ecs_table_str have no public wrapper
// U: World.search + pair_second for groups; query_opts(group_by_callback) + World.path
module flecs_ex_q_group_iter;

import flecs;
import flecs::internal;
import std::io;

fn ulong group_by_relation(internal::EcsWorld* world, internal::EcsTable* table,
	internal::EcsId id, void* ctx)
{
	(void)ctx;
	World w = { .raw = world };
	int index = w.search(table, w.pair(id, flecs::ECS_WILDCARD));
	if (index == -1)
	{
		return 0;
	}
	internal::EcsType* type = internal::ecs_table_get_type(table);
	return w.pair_second(type.array[index]);
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	Entity world_cell = w.entity("WorldCell");
	Entity cell_0_0 = w.entity("Cell_0_0");
	Entity cell_0_1 = w.entity("Cell_0_1");
	Entity cell_1_0 = w.entity("Cell_1_0");
	Entity cell_1_1 = w.entity("Cell_1_1");

	Entity npc = w.entity("Npc");
	Entity merchant = w.entity("Merchant");
	Entity soldier = w.entity("Soldier");
	Entity beggar = w.entity("Beggar");
	Entity mage = w.entity("Mage");

	Entity npc_01 = w.entity();
	w.add_id(npc_01, w.pair(world_cell.id, cell_0_0.id));
	w.add_id(npc_01, merchant.id);
	w.add_id(npc_01, npc.id);
	Entity npc_02 = w.entity();
	w.add_id(npc_02, w.pair(world_cell.id, cell_0_0.id));
	w.add_id(npc_02, merchant.id);
	w.add_id(npc_02, npc.id);

	Entity npc_03 = w.entity();
	w.add_id(npc_03, w.pair(world_cell.id, cell_0_1.id));
	w.add_id(npc_03, beggar.id);
	w.add_id(npc_03, npc.id);
	Entity npc_04 = w.entity();
	w.add_id(npc_04, w.pair(world_cell.id, cell_0_1.id));
	w.add_id(npc_04, soldier.id);
	w.add_id(npc_04, npc.id);

	Entity npc_05 = w.entity();
	w.add_id(npc_05, w.pair(world_cell.id, cell_1_0.id));
	w.add_id(npc_05, mage.id);
	w.add_id(npc_05, npc.id);
	Entity npc_06 = w.entity();
	w.add_id(npc_06, w.pair(world_cell.id, cell_1_0.id));
	w.add_id(npc_06, beggar.id);
	w.add_id(npc_06, npc.id);

	Entity npc_07 = w.entity();
	w.add_id(npc_07, w.pair(world_cell.id, cell_1_1.id));
	w.add_id(npc_07, soldier.id);
	w.add_id(npc_07, npc.id);

	Term[] terms = { { .id = npc.id } };
	QueryOptions opts = {
		.group_by = world_cell.id,
		.group_by_callback = &group_by_relation,
	};
	Query q = w.query_opts(terms, opts);
	defer q.fini();

	io::printfn("All tables:");
	Iter it = q.iter(&w);
	while (it.next())
	{
		String table_str = internal::ecs_table_str(w.raw, it.raw.table).str_view();
		String group_str = w.path({ it.group() });
		io::printfn(" - group %s: table [%s]", group_str, table_str);
		flecs::free_str(group_str);
		flecs::free_str(table_str);
	}
	io::printfn("");

	io::printfn("Tables for cell 1_0:");
	it = q.iter(&w);
	it.set_group(cell_1_0.id);
	while (it.next())
	{
		String table_str = internal::ecs_table_str(w.raw, it.raw.table).str_view();
		String group_str = w.path({ it.group() });
		io::printfn(" - group %s: table [%s]", group_str, table_str);
		flecs::free_str(group_str);
		flecs::free_str(table_str);
	}
}
