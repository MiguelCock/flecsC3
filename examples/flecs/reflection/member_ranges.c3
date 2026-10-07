// Port of Flecs example: reflection/member_ranges
module flecs_ex_refl_ranges;

import flecs;

struct CpuUtilization
{
	double value;
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	w.struct_meta_full(CpuUtilization, (MemberDesc[]){
		{
			.name = "value",
			.range = { .min = 0, .max = 100 },
			.warning_range = { .min = 0, .max = 60 },
			.error_range = { .min = 0, .max = 80 },
		},
	});

	Entity m1 = w.entity("MachineA");
	w.set(CpuUtilization, m1, { .value = 50 });

	Entity m2 = w.entity("MachineB");
	w.set(CpuUtilization, m2, { .value = 75 });

	Entity m3 = w.entity("MachineC");
	w.set(CpuUtilization, m3, { .value = 90 });
}
