// Port of Flecs example: os_api/bake
//
// NOTE: the C example replaces the entire OS API with `bake`'s `ut_*` thread,
// mutex, condition, dlopen and module-lookup implementations. That library is
// not available here, so this port overrides the operations that can be
// implemented standalone (init, fini, atomic inc/dec, abort) and keeps the
// default implementations for the rest.
module flecs_ex_os_api;

import flecs;
import std::io;

fn void custom_init()
{
	io::printfn("[os_api] custom init");
}

fn void custom_fini()
{
	io::printfn("[os_api] custom fini");
}

fn int custom_ainc(int* value)
{
	*value += 1;
	return *value;
}

fn int custom_adec(int* value)
{
	*value -= 1;
	return *value;
}

fn void custom_abort()
{
	io::printfn("[os_api] custom abort");
}

fn void bake_set_os_api()
{
	// Start from the platform defaults, then override selected operations.
	flecs::os_set_api_defaults();

	OsApi api = flecs::os_get_api();
	api.init_ = &custom_init;
	api.fini_ = &custom_fini;
	api.ainc_ = &custom_ainc;
	api.adec_ = &custom_adec;
	api.abort_ = &custom_abort;

	flecs::os_set_api(&api);
}

fn void main()
{
	bake_set_os_api();

	// Exercise the overridden atomic inc/dec through the installed API.
	OsApi api = flecs::os_get_api();
	int counter = 10;
	int incremented = api.ainc_(&counter);
	int decremented = api.adec_(&counter);
	io::printfn("[os_api] counter=%d inc=%d dec=%d", counter, incremented, decremented);

	World w = flecs::create();
	w.fini();

	io::printfn("[os_api] ok");
}
