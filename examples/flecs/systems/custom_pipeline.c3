// Port of Flecs example: systems/custom_pipeline
// G: no public pipeline builder yet — a custom pipeline still requires
//    internal::ecs_pipeline_init + internal::EcsPipelineDesc and the
//    internal::ECS_SYSTEM term id.
module flecs_ex_sys_custom_pipeline;

import flecs;
import flecs::internal;
import std::io;

fn void sys(Iter* it)
{
	(void)it;
	io::printn("System ran!");
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	Entity physics = w.entity("Physics");

	// Pipeline matching systems tagged with Physics (plus EcsSystem).
	internal::EcsPipelineDesc desc = {};
	desc.query.terms[0].id = internal::ECS_SYSTEM;
	desc.query.terms[1].id = physics.id;
	EntityId pipeline = internal::ecs_pipeline_init(w.raw, &desc);
	w.set_pipeline({ pipeline });

	// System tagged with Physics: it is picked up by the custom pipeline.
	w.system("Sys", &sys, physics.id);

	w.progress(0);
}
