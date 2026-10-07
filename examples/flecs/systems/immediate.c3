// Port of Flecs example: systems/immediate
module flecs_ex_sys_immediate;

import flecs;
import std::io;

EntityId g_waiter;
EntityId g_plate;

fn void assign_plate(Iter* it)
{
	World w = { .raw = it.raw.world };
	Query* q_waiter = (Query*)it.ctx();

	foreach (i, plate : it.entities())
	{
		// Find an available waiter.
		Iter qit = q_waiter.iter(&w);
		EntityId waiter = 0;
		if (qit.next())
		{
			waiter = qit.raw.entities[0];
			qit.fini(); // only needed the first match
		}

		if (waiter)
		{
			// Suspend deferring so the assignment is immediately visible.
			w.defer_suspend();
			w.add_pair({ waiter }, g_plate, plate);
			w.defer_resume();

			w.add_pair({ plate }, g_waiter, waiter);

			io::printfn("Assigned %s to %s!",
				w.name_id(waiter).str_view(),
				w.name_id(plate).str_view());
		}
	}
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	Entity waiter_tag = w.entity("Waiter");
	Entity plate_tag = w.entity("Plate");
	g_waiter = waiter_tag.id;
	g_plate = plate_tag.id;

	// Query for waiters without a plate.
	Term[] waiter_terms = {
		{ .id = waiter_tag.id },
		{ .id = w.pair(plate_tag.id, flecs::ECS_WILDCARD), .oper = Oper.NOT },
	};
	Query q_waiter = w.query(waiter_terms);
	defer q_waiter.fini();

	// Immediate system matching plates without a waiter, with the query as ctx.
	Term[] plate_terms = {
		{ .id = plate_tag.id },
		{ .id = w.pair(waiter_tag.id, flecs::ECS_WILDCARD), .oper = Oper.NOT },
	};
	SystemOptions opts = {
		.phase = flecs::ECS_ON_UPDATE,
		.immediate = true,
		.ctx = (void*)&q_waiter,
		.terms = plate_terms,
	};
	w.system_opts("AssignPlate", &assign_plate, opts);

	// Create waiters and plates.
	Entity waiter_1 = w.entity("waiter_1");
	w.add_id(waiter_1, waiter_tag.id);
	Entity waiter_2 = w.entity("waiter_2");
	w.add_id(waiter_2, waiter_tag.id);
	Entity waiter_3 = w.entity("waiter_3");
	w.add_id(waiter_3, waiter_tag.id);
	(void)waiter_2;
	(void)waiter_3;

	Entity plate_1 = w.entity("plate_1");
	w.add_id(plate_1, plate_tag.id);
	(void)plate_1;

	Entity plate_2 = w.entity("plate_2");
	w.add_id(plate_2, plate_tag.id);
	w.add_id(plate_2, w.pair(waiter_tag.id, waiter_1.id));

	Entity plate_3 = w.entity("plate_3");
	w.add_id(plate_3, plate_tag.id);
	(void)plate_3;

	w.add_id(waiter_1, w.pair(plate_tag.id, plate_2.id));

	w.progress(0);
}
