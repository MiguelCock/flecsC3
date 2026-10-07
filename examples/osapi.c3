module osapi;
import flecs;
import std::io;

fn void main()
{
	flecs::os_set_api_defaults();
	flecs::OsApi api = flecs::os_get_api();
	io::printfn("after defaults: malloc_=%s log_=%s", api.malloc_ != null ? "yes" : "no", api.log_ != null ? "yes" : "no");
	flecs::os_set_api(&api);
	World w = flecs::create();
	w.fini();
	io::printfn("ok");
}
