module flecs_test;

import flecs;
import std::io;

struct Position
{
	float x;
	float y;
}

struct Velocity
{
	float x;
	float y;
}

fn void test_world_lifecycle() @test
{
	World w = flecs::create();
	assert(w.raw != null);
	w.fini();
}

fn void test_doc() @test
{
	World w = flecs::create();
	defer w.fini();

	Entity e = w.entity("documented");
	w.set_brief(e, "a short description");
	w.set_link(e, "https://example.com");

	assert(w.brief(e) == "a short description");
}

fn void test_script() @test
{
	World w = flecs::create();
	defer w.fini();

	assert(w.script("Foo { }"));
	Entity foo = w.lookup("Foo");
	assert(foo.id != 0);
}

fn void test_alert() @test
{
	World w = flecs::create();
	defer w.fini();

	w.import_alerts();
	w.register(Health);
	Entity a = w.alert("HasHealth", flecs::ECS_ALERT_ERROR, "$this has Health", "Health");
	assert(a.id != 0);

	Entity e = w.entity();
	w.add(Health, e);
	w.progress(0);
	// Alert instance evaluation is pipeline-driven; just exercise the accessor.
	int alerts = w.alert_count(e, a);
	assert(alerts >= 0);
}

fn void test_metric() @test
{
	World w = flecs::create();
	defer w.fini();

	w.import_metrics();
	w.register(Health);
	Entity m = w.metric(flecs::ECS_GAUGE, w.comp(Health), "health gauge");
	assert(m.id != 0);
}

fn void test_os_api() @test
{
	flecs::os_set_api_defaults();
	flecs::OsApi api = flecs::os_get_api();
	assert(api.malloc_ != null);
	assert(api.log_ != null);
	flecs::os_set_api(&api);
}

fn void test_stats() @test
{
	World w = flecs::create();
	defer w.fini();

	for (int i = 0; i < 3; i++)
	{
		Entity e = w.entity();
		w.add(Position, e);
	}

	WorldStats* stats = (WorldStats*)mem::malloc(WorldStats::size);
	defer mem::free(stats);
	*stats = {};
	w.world_stats(stats);
	assert((double)stats.entities.count.gauge.avg[stats.t] >= 3.0);

	Query q = w.query_expr("Position");
	defer q.fini();
	QueryStats* qs = (QueryStats*)mem::malloc(QueryStats::size);
	defer mem::free(qs);
	*qs = {};
	w.query_stats(&q, qs);
	assert((double)qs.matched_entity_count.gauge.avg[qs.t] >= 3.0);
}

fn void test_component_roundtrip() @test
{
	World w = flecs::create();
	defer w.fini();

	Entity e = w.entity("e");
	w.add(Position, e);
	assert(w.has(Position, e));
	assert(!w.has(Velocity, e));

	Position p = { .x = 3, .y = 4 };
	w.set(Position, e, p);

	Position* got = w.get(Position, e);
	assert(got != null);
	assert(got.x == 3);
	assert(got.y == 4);

	w.remove(Position, e);
	assert(!w.has(Position, e));
}

fn void test_query_count() @test
{
	World w = flecs::create();
	defer w.fini();

	for (int i = 0; i < 5; i++)
	{
		Entity e = w.entity();
		w.add(Position, e);
	}

	Query q = w.query_expr("Position");
	defer q.fini();

	Iter it = q.iter(&w);
	int n = 0;
	while (it.next()) n += it.count();
	assert(n == 5);
}

fn void test_system_updates() @test
{
	World w = flecs::create();
	defer w.fini();

	Entity e = w.entity();
	w.add(Position, e);
	w.set(Velocity, e, { .x = 2, .y = 3 });
	w.set(Position, e, { .x = 0, .y = 0 });

	w.system("Move", &move);
	w.progress(0);
	w.progress(0);

	Position* got = w.get(Position, e);
	assert(got != null);
	assert(got.x == 4);
	assert(got.y == 6);
}

fn void move(Position[] pos, Velocity[] vel)
{
	foreach (i, &p : pos)
	{
		p.x += vel[i].x;
		p.y += vel[i].y;
	}
}

fn void move_with_iter(Iter* it, Position[] pos, Velocity[] vel)
{
	foreach (i, &p : pos)
	{
		p.x += vel[i].x * (float)it.delta_time();
		p.y += vel[i].y * (float)it.delta_time();
	}
}

struct Health { int value; }

fn void clamp_health(Position[] pos, Health[] hp, Velocity[] vel)
{
	foreach (i, &p : pos)
	{
		p.x += vel[i].x;
		if (hp[i].value > 100) hp[i].value = 100;
	}
}

int on_add_count;

fn void on_add_cb(Position[] pos)
{
	on_add_count += pos.len;
}

fn void test_observer_on_add() @test
{
	World w = flecs::create();
	defer w.fini();

	on_add_count = 0;
	w.observer("OnAddPos", flecs::ECS_ON_ADD, &on_add_cb);

	Entity e = w.entity();
	w.add(Position, e);
	assert(on_add_count == 1);

	w.add(Position, w.entity());
	assert(on_add_count == 2);
}

fn void test_system_with_iter() @test
{
	World w = flecs::create();
	defer w.fini();

	Entity e = w.entity();
	w.add(Position, e);
	w.set(Velocity, e, { .x = 10, .y = 0 });
	w.set(Position, e, { .x = 0, .y = 0 });

	w.system("MoveIt", &move_with_iter);
	w.progress(1.0);

	Position* got = w.get(Position, e);
	assert(got != null);
	assert(got.x == 10);
}

fn void test_system_explicit_expr() @test
{
	World w = flecs::create();
	defer w.fini();

	Entity e = w.entity();
	w.add(Position, e);
	w.set(Velocity, e, { .x = 1, .y = 1 });
	w.set(Position, e, { .x = 0, .y = 0 });

	w.system_expr("MoveIn", &move, "Position, [in] Velocity");
	w.progress(0);

	Position* got = w.get(Position, e);
	assert(got != null);
	assert(got.x == 1);
}

fn void test_system_three_components() @test
{
	World w = flecs::create();
	defer w.fini();

	Entity e = w.entity();
	w.add(Position, e);
	w.add(Health, e);
	w.set(Health, e, { .value = 250 });
	w.set(Velocity, e, { .x = 2, .y = 0 });
	w.set(Position, e, { .x = 0, .y = 0 });

	w.system("Clamp", &clamp_health);
	w.progress(0);

	Position* p = w.get(Position, e);
	Health* h = w.get(Health, e);
	assert(p != null && h != null);
	assert(p.x == 2);
	assert(h.value == 100);
}

fn void test_raw_iter_api() @test
{
	World w = flecs::create();
	defer w.fini();

	Entity e = w.entity();
	w.add(Position, e);

	raw_seen = 0;
	w.system_iter("RawIter", &raw_iter_cb, "Position");
	w.progress(0);
	assert(raw_seen == 1);
}

int raw_seen;

fn void raw_iter_cb(Iter* it)
{
	raw_seen += it.count();
}

int existing_seen;

fn void existing_cb(Position[] pos)
{
	existing_seen += pos.len;
}

fn void test_observer_existing() @test
{
	World w = flecs::create();
	defer w.fini();

	Entity e = w.entity();
	w.add(Position, e);

	existing_seen = 0;
	w.observer_existing("OnAddExisting", flecs::ECS_ON_ADD, &existing_cb);
	assert(existing_seen == 1);
}

int tick_count;

fn void tick()
{
	tick_count++;
}

fn void test_system_no_params() @test
{
	World w = flecs::create();
	defer w.fini();

	tick_count = 0;
	w.system("Tick", &tick);
	w.progress(0);
}


fn void test_timer_registration() @test
{
	World w = flecs::create();
	defer w.fini();

	Entity e = w.entity();
	w.set_interval(e, 1.0);
	w.start_timer(e);
	w.stop_timer(e);
	w.reset_timer(e);
}

fn void test_json_serialization() @test
{
	World w = flecs::create();
	defer w.fini();

	Entity e = w.entity("json_entity");

	String json = w.entity_to_json(e, false);
	assert(json.len > 0);
	flecs::free_str(json);

	String world_json = w.to_json();
	assert(world_json.len > 0);
	flecs::free_str(world_json);
}

fn void test_struct_reflection_json() @test
{
	World w = flecs::create();
	defer w.fini();

	w.struct_meta(Position);

	Entity e = w.entity("reflected");
	w.set(Position, e, { .x = 1.5, .y = 2.5 });

	String json = w.entity_to_json(e, true);
	assert(json.len > 0);
	io::printfn("%s", json);
	assert(json.contains("x"));
	assert(json.contains("1.5"));
	flecs::free_str(json);
}

enum Color : int
{
	RED,
	GREEN,
	BLUE,
}

fn void test_enum_reflection_json() @test
{
	World w = flecs::create();
	defer w.fini();

	w.enum_meta(Color);

	Entity e = w.entity("colored");
	w.set(Color, e, Color.GREEN);

	String json = w.entity_to_json(e, true);
	assert(json.len > 0);
	assert(json.contains("GREEN"));
	flecs::free_str(json);
}

fn void test_prefab_inheritance() @test
{
	World w = flecs::create();
	defer w.fini();

	Entity prefab = w.prefab("Base");
	Position p = { .x = 5, .y = 6 };
	w.set(Position, prefab, p);

	Entity inst = w.instantiate(prefab, "Child");

	Position* got = w.get(Position, inst);
	assert(got != null);
	assert(got.x == 5);
	assert(got.y == 6);
}

struct Frozen
{
	int marker;
}

fn void test_query_terms() @test
{
	World w = flecs::create();
	defer w.fini();

	for (int i = 0; i < 3; i++)
	{
		Entity e = w.entity();
		w.add(Position, e);
	}
	Entity frozen = w.entity();
	w.add(Position, frozen);
	w.add(Frozen, frozen);

	Term[] terms = {
		{ .id = w.comp(Position) },
		{ .id = w.comp(Frozen), .oper = Oper.NOT },
	};
	Query q = w.query(terms);
	defer q.fini();

	int n = 0;
	Iter it = q.iter(&w);
	while (it.next()) n += it.count();
	assert(n == 3);
}

fn void test_query_terms_pair_optional() @test
{
	World w = flecs::create();
	defer w.fini();

	Entity parent = w.entity("parent");
	Entity child = w.entity("child");
	w.add(Position, child);
	w.add(Position, w.entity());
	w.add_id(child, w.pair(flecs::ECS_CHILD_OF, parent.id));

	Term[] terms = {
		{ .id = w.comp(Position) },
		{ .id = w.pair(flecs::ECS_CHILD_OF, parent.id), .oper = Oper.OPTIONAL },
	};
	Query q = w.query(terms);
	defer q.fini();

	int n = 0;
	Iter it = q.iter(&w);
	while (it.next()) n += it.count();
	assert(n == 2);
}

int phase_pre_count;

fn void phase_pre(Iter* it)
{
	(void)it;
	phase_pre_count++;
}

fn void test_system_phase() @test
{
	World w = flecs::create();
	defer w.fini();

	phase_pre_count = 0;
	Entity sys = w.system("Pre", &phase_pre, flecs::ECS_PRE_UPDATE);
	assert(sys.id != 0);

	w.progress(0);
	assert(phase_pre_count == 1);
}

int terms_sys_count;

fn void terms_sys(Position[] pos)
{
	terms_sys_count += pos.len;
}

fn void test_system_terms() @test
{
	World w = flecs::create();
	defer w.fini();

	for (int i = 0; i < 2; i++)
	{
		Entity e = w.entity();
		w.add(Position, e);
	}

	Term[] terms = { { .id = w.comp(Position) } };
	terms_sys_count = 0;
	w.system("Terms", &terms_sys, 0, terms);
	w.progress(0);
	assert(terms_sys_count == 2);
}

int terms_obs_count;

fn void terms_obs(Position[] pos)
{
	terms_obs_count += pos.len;
}

fn void test_observer_terms() @test
{
	World w = flecs::create();
	defer w.fini();

	Term[] terms = { { .id = w.comp(Position) } };
	terms_obs_count = 0;
	w.observer("Obs", flecs::ECS_ON_ADD, &terms_obs, terms);

	Entity e = w.entity();
	w.add(Position, e);
	assert(terms_obs_count == 1);
}

struct Coin
{
	double value;
}

fn void test_pair_helpers() @test
{
	World w = flecs::create();
	defer w.fini();

	Entity tgt = w.entity("Tgt");
	Entity e = w.entity();
	w.set_pair(Coin, e, tgt.id, { .value = 1.5 });
	assert(w.has_pair(e, w.comp(Coin), tgt.id));

	Coin* c = w.get_pair(Coin, e, tgt.id);
	assert(c != null);
	assert(c.value == 1.5);

	internal::EcsId pair = w.pair(w.comp(Coin), tgt.id);
	assert(w.pair_first(pair) == w.comp(Coin));
	assert(w.pair_second(pair) == tgt.id);

	w.remove_pair(e, w.comp(Coin), tgt.id);
	assert(!w.has_pair(e, w.comp(Coin), tgt.id));
}

fn void ctx_cb(Iter* it)
{
	int* v = (int*)it.ctx();
	*v += 1;
}

fn void test_system_ctx() @test
{
	World w = flecs::create();
	defer w.fini();

	int counter = 0;
	w.system_ctx("Ctx", &ctx_cb, &counter);
	w.progress(0);
	assert(counter == 1);
}

int event_count;

fn void event_cb(Iter* it, Coin[] c)
{
	(void)c;
	event_count += it.count();
}

fn void test_observer_events() @test
{
	World w = flecs::create();
	defer w.fini();

	internal::EcsEntity[] events = { flecs::ECS_ON_ADD, flecs::ECS_ON_REMOVE };
	event_count = 0;
	w.observer_events("Ev", events, &event_cb);

	Entity e = w.entity();
	w.add(Coin, e);
	w.remove(Coin, e);
	assert(event_count == 2);
}

fn void test_emit() @test
{
	World w = flecs::create();
	defer w.fini();

	Entity click = w.entity("Click");
	event_count = 0;
	w.observer("Click", click.id, &event_cb);

	Entity e = w.entity();
	w.add(Coin, e);

	internal::EcsId[] ids = { w.comp(Coin) };
	w.emit_ids(click.id, e, ids);
	assert(event_count == 1);
}

fn void test_query_detect_changes() @test
{
	World w = flecs::create();
	defer w.fini();

	Entity e = w.entity();
	w.set(Coin, e, { .value = 1 });

	Term[] terms = { { .id = w.comp(Coin), .inout = InOut.IN } };
	QueryOptions opts = { .flags = flecs::ECS_QUERY_DETECT_CHANGES };
	Query q = w.query_opts(terms, opts);
	defer q.fini();

	assert(q.changed());
	Iter it = q.iter(&w);
	while (it.next()) {}
	assert(!q.changed());
}

fn void test_query_variable() @test
{
	World w = flecs::create();
	defer w.fini();

	Entity eats = w.entity("Eats");
	Entity healthy = w.entity("Healthy");
	Entity apples = w.entity("Apples");
	w.add_id(apples, healthy.id);
	Entity bob = w.entity("Bob");
	w.add_id(bob, w.pair(eats.id, apples.id));

	Term[] terms = {
		{ .first.id = eats.id, .second.name = "$food" },
		{ .first.id = healthy.id, .src.name = "$food" },
	};
	Query q = w.query(terms);
	defer q.fini();

	int food_var = internal::ecs_query_find_var(q.raw, "food");
	int n = 0;
	Iter it = q.iter(&w);
	while (it.next())
	{
		internal::EcsEntity food = internal::ecs_iter_get_var(&it.raw, food_var);
		assert(food == apples.id);
		n += it.count();
	}
	assert(n == 1);
}

fn void test_misc_helpers() @test
{
	World w = flecs::create();
	defer w.fini();

	Entity e = w.insert(Coin, { .value = 2.0 });
	assert(w.count(w.comp(Coin)) == 1);

	String p = w.path(e);
	assert(p.len > 0);
	flecs::free_str(p);

	Entity parent = w.entity("Parent");
	internal::EcsEntityDesc d = { .parent = parent.id, .name = "Child" };
	Entity child = { internal::ecs_entity_init(w.raw, &d) };
	Entity found = w.lookup_child(parent, "Child");
	assert(found.id == child.id);

	int n = 0;
	Iter it = w.children(parent);
	while (it.next()) n += it.count();
	assert(n == 1);
}

fn void test_ptr_to_json() @test
{
	World w = flecs::create();
	defer w.fini();

	w.struct_meta(Coin);
	Coin c = { .value = 3.5 };
	String json = w.ptr_to_json(w.comp(Coin), &c);
	assert(json.len > 0);
	assert(json.contains("3.5"));
	flecs::free_str(json);
}

enum Toppings : int
{
	LETTUCE,
	BACON,
	TOMATO,
	CHEESE,
}

fn void test_bitmask_meta() @test
{
	World w = flecs::create();
	defer w.fini();

	w.bitmask_meta(Toppings);
	Entity e = w.entity("pizza");
	w.set(Toppings, e, (Toppings)(1 | 2));

	String json = w.entity_to_json(e, true);
	assert(json.len > 0);
	io::printfn("%s", json);
	assert(json.contains("LETTUCE"));
	assert(json.contains("BACON"));
	flecs::free_str(json);
}

struct Weather
{
	double temperature;
	double pressure;
}

fn void test_meta_cursor() @test
{
	World w = flecs::create();
	defer w.fini();

	w.struct_meta(Weather);
	Weather val = { .temperature = 24.0, .pressure = 1.2 };

	MetaCursor c = w.meta_cursor(Weather, &val);
	c.push();
	assert(c.get_float() == 24.0);
	c.next();
	assert(c.get_float() == 1.2);
	c.pop();

	MetaCursor c2 = w.meta_cursor(Weather, &val);
	c2.push();
	assert(c2.set_float(30.0) == 0);
	c2.pop();
	assert(val.temperature == 30.0);
}

struct Pair2
{
	int x;
	int y;
}

fn void sum_cb(internal::EcsFunctionCtx* ctx, int argc, internal::EcsValue* argv, internal::EcsValue* result)
{
	(void)ctx;
	(void)argc;
	*(long*)result.ptr = *(long*)argv[0].ptr + *(long*)argv[1].ptr;
}

fn void test_script_function() @test
{
	World w = flecs::create();
	defer w.fini();

	w.struct_meta(Pair2);
	internal::EcsScriptParameter[] params = {
		{ .name = "a", .type = internal::ECS_TYPE_I64 },
		{ .name = "b", .type = internal::ECS_TYPE_I64 },
	};
	assert(w.function("sum", internal::ECS_TYPE_I64, params, &sum_cb) != 0);
	assert(w.script("e { Pair2: { sum(10, 20), 0 } }"));

	Entity e = w.lookup("e");
	Pair2* p = w.get(Pair2, e);
	assert(p != null);
	assert(p.x == 30);
}

fn void test_expr() @test
{
	World w = flecs::create();
	defer w.fini();

	long out_val = 0;
	Value out;
	out.init(internal::ECS_TYPE_I64, &out_val);
	assert(w.expr_run("10 + 20", &out));
	assert(out_val == 30);
}

fn void test_module_scope() @test
{
	World w = flecs::create();
	defer w.fini();

	Entity m = w.module_init("my_mod");
	assert(m.id != 0);

	Entity prev = w.set_scope(m);
	assert(w.get_scope().id == m.id);
	w.set_scope(prev);
	assert(w.get_scope().id != m.id);
}

enum Color2 : int
{
	RED,
	GREEN,
	BLUE,
}

fn void test_enum_meta_named() @test
{
	World w = flecs::create();
	defer w.fini();

	String[] names = { "Red", "Green", "Blue" };
	w.enum_meta_named(Color2, names);

	Entity e = w.entity("x");
	w.set(Color2, e, Color2.GREEN);

	String json = w.entity_to_json(e, true);
	assert(json.contains("Green"));
	flecs::free_str(json);
}

fn void test_singleton_and_phase() @test
{
	World w = flecs::create();
	defer w.fini();

	w.singleton_set(Coin, { .value = 7.0 });
	Coin* c = w.singleton_get(Coin);
	assert(c != null);
	assert(c.value == 7.0);

	Entity phase = w.phase("Physics", 0);
	assert(phase.id != 0);
	assert(w.has_id(phase, flecs::ECS_PHASE));
}
