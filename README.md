# flecs.c3l

Idiomatic [C3](https://c3-lang.org) bindings for the [Flecs](https://www.flecs.dev) entity
component system (ECS), version **4.1.6**.

The library bundles the amalgamated Flecs C sources, so it is self-contained: no
system-wide Flecs install is required.

```c++
import flecs;

struct Position { float x; float y; }
struct Velocity { float x; float y; }

fn void move(Position[] pos, Velocity[] vel)
{
    foreach (i, &p : pos)
    {
        p.x += vel[i].x;
        p.y += vel[i].y;
    }
}

fn int main()
{
    World world = flecs::create();
    defer world.fini();

    Entity e = world.entity("player");
    world.add(Position, e);
    world.set(Velocity, e, { .x = 1, .y = 2 });
    world.set(Position, e, { .x = 0, .y = 0 });

    world.system("Move", &move);
    world.progress(0);

    Position* p = world.get(Position, e);
    io::printfn("(%.1f, %.1f)", p.x, p.y);

    Query q = world.query_expr("Position, Velocity");
    defer q.fini();
    return 0;
}
```

See `examples/quickstart.c3` for the complete program.

## Requirements

- C3 compiler `c3c` 0.8.x or newer.
- A C compiler (`cc`) available on `PATH` (used to compile the bundled `flecs.c`).

## Using the library

Place `flecs.c3l` in your project's library search path and add it as a dependency:

```json
{
  "dependency-search-paths": [ "lib" ],
  "dependencies": [ "flecs" ]
}
```

Then:

```
c3c run
```

## API overview

| Area | API |
|------|-----|
| World | `create`, `init`, `fini`, `progress`, `quit`, `set_target_fps`, `set_time_scale`, `set_threads`, `entity`, `lookup`, `lookup_child`, `children`, `path`, `id_str`, `name`, `target`, `destroy`, `count`, `run_system`, `insert`, `singleton_set/get`, `phase`, `prefab_child`, `sleep`, `search`, `module_init`, `import_module`, `set_scope`, `get_scope`, `defer_begin/end`, `defer_suspend/resume` |
| Components | `add`, `remove`, `set`, `get`, `get_mut`, `ensure`, `has`, `owns`, `modified`, `register`, `component_id`, `remove_id`, `has_id` |
| Pairs | `pair`, `add_pair`, `remove_pair`, `has_pair`, `has_pair_rel`, `new_pair`, `get_pair`, `set_pair`, `get_pair_second`, `set_pair_second`, `pair_first`, `pair_second` |
| Queries | `query(Term[])`, `query_expr(expr)`, `query_opts(Term[], QueryOptions)`, `iter`, `changed`, `find_var`, `group_info`, `group_ctx`, `match_count` |
| Iteration | `next`, `count`, `entities`, `entity_at`, `field(T, i)`, `field_id`, `delta_time`, `name`, `get_var`/`set_var`, `is_true`, `changed`, `skip`, `group`/`set_group`, `to_json`, `ctx`, `fini` |
| Systems | `system(name, cb[, phase[, terms]])`, `system_expr(...)`, `system_opts(...)`, `system_ctx(...)`, `system_iter(...)` |
| Observers | `observer(...)`, `observer_expr(...)`, `observer_existing(...)`, `observer_events(...)`, `observer_ctx(...)`, `observer_iter*` |
| Events | `emit`, `emit_ids`, `emit_param`, `enqueue`, `enqueue_ids`, `enqueue_param` |
| Prefabs | `prefab(name)`, `instantiate(prefab, name?)`, `prefab_child(parent, name)`, `add_pair(e, ECS_IS_A, prefab)` |
| Timers | `set_interval`, `set_timeout`, `set_rate`, `start/stop/reset_timer`, `randomize_timers`, `set_tick_source` |
| Pipeline | `get_pipeline`, `set_pipeline`, `run_pipeline` |
| JSON | `to_json`, `entity_to_json`, `from_json`, `entity_from_json`, `ptr_to_json`, `ptr_to_expr`, `array_to_json`, `free_str` |
| Meta | `struct_meta(T)` (recursive), `struct_meta_full(T, MemberDesc[])`, `enum_meta(T)`, `enum_meta_named(T, names)`, `constdef_meta(T, names, values)`, `bitmask_meta(T)`, `meta_cursor(T, ptr)` |
| Opaque | `opaque(T, as_type, OpaqueOptions)`, `type_serializer(type)` |
| Script | `script(code)`, `script_file(path)`, `script_init(name, code)`, `script_update(script, instance, code)`, `script_vars()`, `function(...)`, `method(...)`, `expr_run`, `expr_parse`, `expr_eval` |
| Docs | `set_brief`, `brief`, `set_detail`, `set_link`, `set_color` |
| Metrics | `import_metrics`, `metric(kind, id, brief?)`, `import_stats` |
| Alerts | `import_alerts`, `alert(name, severity, message, expr)`, `alert_count` |
| App | `app_run(frames?, target_fps?)` |
| Units | `import_units`, `unit(symbol, ...)` |
| REST | `rest_server(port?)`, `RestServer.fini` |
| Logging | `set_log_level`, `log_level`, `enable_log_colors`, `enable_log_timestamp` |
| OS API | `os_get_api`, `os_set_api`, `os_set_api_defaults`, `set_os_abort`, `set_os_log` |
| Stats | `world_stats`, `query_stats`, `system_stats`, `pipeline_stats`, `pipeline_stats_fini` (`WorldStats`/`QueryStats`/`SystemStats`/`PipelineStats`) |

### Components and type safety

Component types are registered lazily and cached per world, so the same type can
be used across multiple worlds:

```c++
world.add(Position, e);
world.set(Position, e, { .x = 1, .y = 2 });
Position* p = world.get(Position, e);     // Position*
bool has = world.has(Position, e);
world.remove(Position, e);
```

Component types are registered under their simple type name (as the C
`ECS_COMPONENT` macro does), so type names should be unique across modules if you
rely on query expression strings.

Iteration over a table batch yields a field array pointer:

```c++
Iter it = q.iter(&world);
while (it.next())
{
    Position* p = it.field(Position, 0);
    foreach (idx, entity : it.entities())
    {
        p[idx].x += 1;
    }
}
```

Cross-component iteration with a positional field index is available through
`it.field(T, i)`. Query expressions use the standard Flecs query language, e.g.
`"Position, Velocity"`, `"[in] Position, [out] Velocity"`, `"ChildOf(player)"`.

### Reflected systems & observers

Callbacks take the component **slices** they use; the query is inferred from the
parameter types at compile time (no functional builder chaining):

```c++
fn void move(Position[] pos, Velocity[] vel)
{
    foreach (i, &p : pos) { p.x += vel[i].x; p.y += vel[i].y; }
}

world.system("Move", &move);                                 // inferred, OnUpdate
world.system("Move", &move, flecs::ECS_PRE_UPDATE);          // inferred + phase
world.system_expr("Move", &move, "Position, [in] Velocity"); // explicit query string
```

Rules:

- Every parameter is a component slice (`Position[]`) or pointer (`Position*`).
- An optional **leading `Iter*`** exposes `it.delta_time()`, `it.entities()`, etc.
- Inferred terms are `inout`. Use `system_expr` (or term descriptors) to set
  `[in]`/`[out]`; parameters are still registered so names resolve.
- `phase` is the 3rd argument (default `ECS_ON_UPDATE`); terms are the optional 4th.
- Any number of component parameters is supported (bounded by Flecs' 32-term limit).

Observers work the same way (terms instead of phase):

```c++
fn void on_add(Position[] pos) { ... }
world.observer("OnAdd", flecs::ECS_ON_ADD, &on_add);
world.observer_expr("OnAdd", flecs::ECS_ON_ADD, &on_add, "Position");
world.observer_existing("OnAddExisting", flecs::ECS_ON_ADD, &on_add);
```

For full control, the iterator-based API remains available as
`system_iter` / `observer_iter` / `observer_iter_existing`, where the callback is
`fn void(Iter* it)` and uses `it.field(T, i)`.

### Term-based queries

`query` takes an array of `Term` descriptors; `query_expr` takes a string.
`InOut` and `Oper` set access and the operator (`Oper.OR` belongs on the
**preceding** term of an or-chain). `Term.src`/`first`/`second` (`TermRef`)
express sources, variables and pair elements; combine with the traversal flag
constants (`ECS_SELF`, `ECS_UP`, `ECS_TRAV`, `ECS_CASCADE`, `ECS_IS_VARIABLE`,
`ECS_IS_ENTITY`, `ECS_IS_NAME`).

```c++
Term[] terms = {
    { .id = world.comp(Position) },                                  // AND, inout
    { .id = world.comp(Velocity), .inout = InOut.IN },               // read-only
    { .id = world.comp(Frozen), .oper = Oper.NOT },                  // must not have
    { .id = world.pair(flecs::ECS_CHILD_OF, parent.id), .oper = Oper.OPTIONAL },
};
Query q = world.query(terms);
Query q2 = world.query_expr("Position, [in] Velocity");              // string form

// Variables and traversal:
Term[] vars = {
    { .first.id = world.comp(Eats), .second.name = "$food" },
    { .first.id = world.comp(Healthy), .src.name = "$food" },
};
// Position from self or from a parent:
Term[] up = {
    { .id = world.comp(Position) },
    { .id = world.comp(Position), .src.id = ECS_UP, .trav = flecs::ECS_CHILD_OF },
};

// Full options: change detection, caching, ordering, grouping.
QueryOptions opts = { .flags = ECS_QUERY_DETECT_CHANGES };
Query q3 = world.query_opts(terms, opts);
```

`world.add_id(e, id)` adds a raw component/pair id; `world.pair(a, b)` builds a
pair id, and `world.add_pair/remove_pair/has_pair/get_pair/set_pair` +
`get_pair_second/set_pair_second` cover the common pair operations. See
`examples/flecs/queries/` and `examples/flecs/relationships/`.

### Events

```c++
Entity click = world.entity("Click");
world.observer_events("OnAddOrRemove", (internal::EcsEntity[]){ flecs::ECS_ON_ADD, flecs::ECS_ON_REMOVE }, &cb);
world.emit(click.id, widget);                       // or emit_ids / emit_param
world.defer_begin();
world.enqueue_param(click.id, widget, &payload);    // delivered on defer_end
world.defer_end();
```

### System & observer context

A reflected callback can read user context via `Iter.ctx()`:

```c++
fn void collide(Iter* it) { CollisionCtx* ctx = (CollisionCtx*)it.ctx(); ... }
world.system_ctx("Collide", &collide, ctx_ptr);
// full options (immediate, multi_threaded, interval, rate, tick_source, run, ctx):
world.system_opts("Sys", &cb, (SystemOptions){ .immediate = true });
```

### Reflection (meta)

`struct_meta` derives member names, offsets and primitive types from C3 type
reflection (recursively registering nested struct/enum members, fixed arrays,
and `Entity` members as the entity type); `struct_meta_full` adds per-member
units/ranges. `enum_meta` registers C3 enums, `enum_meta_named` supplies original
casing (C3 enum members are uppercase), `constdef_meta` handles `constdef` sets,
and `bitmask_meta` registers an enum as a bitmask (ordinal `n` -> flag `1 << n`).
`ptr_to_json`/`ptr_to_expr`/`array_to_json` serialize values by type;
`world.opaque(T, as_type, OpaqueOptions)` registers an opaque type; and
`world.meta_cursor(T, ptr)` walks/reads/writes values at runtime:

```c++
Weather w0 = { .temperature = 24, .pressure = 1.2 };
MetaCursor c = world.meta_cursor(Weather, &w0);
c.push();
double t = c.get_float();     // 24
c.next();
c.set_float(30);              // write temperature
c.pop();
```

```c++
struct Position { float x; float y; }
enum Color : int { RED, GREEN, BLUE }

world.struct_meta(Position);
world.enum_meta(Color);

world.set(Position, e, { .x = 1.5, .y = 2.5 });
world.set(Color, e, Color.GREEN);
io::printn(world.entity_to_json(e, true));
// {"name":"player", "components":{"Position":{"x":1.5, "y":2.5}, "Color":"GREEN"}}
```

Member types are mapped to Flecs' built-in meta types (bool/int/float/String).
`constdef` sets are not supported for `enum_meta` (their reflected values do not
expose names).

### Scripting

```c++
world.script("Foo { Position, Velocity }");   // returns bool
world.script_file("entities.flecs");
```

### Addons not imported by default

`metrics`, `alerts` and `units` are not imported by `ecs_init()`; call
`import_metrics()` / `import_alerts()` / `import_units()` (or `import_units`)
before using them.

```c++
world.import_alerts();
world.register(Health);
Entity a = world.alert("HasHealth", flecs::ECS_ALERT_ERROR, "$this has Health", "Health");
```

The REST server exposes the world over HTTP for the Flecs explorer:

```c++
RestServer rs = world.rest_server(27750);
defer rs.fini();
```

## Architecture

```
flecs.c3l/
├── manifest.json          # c-sources/cflags/targets
├── c/flecs.c, c/flecs.h   # vendored Flecs 4.1.6 amalgamation + MIT license
├── internal.c3i           # flecs::internal — raw FFI types (hand-written)
├── internal_funcs.c3i     # flecs::internal — core extern functions
├── internal_meta.c3i      # flecs::internal — meta addon
├── internal_meta2.c3i     # flecs::internal — meta cursor / opaque / units / serializer
├── internal_script2.c3i   # flecs::internal — script functions / vars / expressions
├── internal_json.c3i      # flecs::internal — json addon
├── internal_addons.c3i    # flecs::internal — doc/script/metrics/alerts/app/units/http/rest
├── internal_stats.c3i     # flecs::internal — stats addon
├── internal_os.c3i        # flecs::internal — os_api
├── internal_extra.c3i     # flecs::internal — json/script/stats extras
├── internal_log.c3i       # flecs::internal — log addon
└── flecs.c3               # flecs — idiomatic public API
```

- `flecs::internal` mirrors the C API 1:1 and is **not** part of the supported
  surface. It exists so the public API and advanced users can reach the raw
  bindings.
- The public `flecs` module is the intended entry point.

### Struct layout

Because `ecs_iter_t` and the descriptor structs are passed by value, the C3
struct layouts must match the C ones exactly. `test/layout_test.c3` asserts the
sizes and offsets of the mirrored structs against the values produced by the
bundled amalgamated build. Run `c3c test` after changing the C flags or Flecs
version.

Flecs is compiled in its default (debug) configuration. If you switch
`flecs.c3l/manifest.json` to build with `-DFLECS_NDEBUG`, update `EcsRef` in
`internal.c3i` (the `id` field is debug-only) and the expected values in the
layout test.

## Tests

```
c3c test                 # unit + ABI layout tests (45)
c3c run smoke            # runs examples/quickstart.c3
./scripts/run_examples.sh  # builds + runs all ported Flecs examples (98)
```

`examples/flecs/` mirrors the Flecs C example tree (entities, relationships,
prefabs, observers, queries, systems, reflection, script, modules, explorer,
os_api) — 98 runnable C3 ports, all built+runnable via the runner. Examples use
`flecs::internal` only for the few remaining low-level surfaces (table/type
introspection, component hooks, runtime-created components, meta serializer
op-walking, script var/expr plumbing) and document each with `G:` comments.

## Coverage & roadmap

Bound today:

- Core ECS: worlds, entities, components, types, iterators, queries, observers,
  systems, pipelines, timers, prefabs, refs, tables.
- All default addons: `json`, `log`, `meta` (struct/enum/bitmask/opaque + cursor),
  `script` (incl. functions/vars/expressions), `doc`, `metrics`, `alerts`, `app`,
  `units`, `stats`, `rest`/`http` (server lifecycle), and a full `os_api` surface.

The whole public Flecs 4.1.6 API (excluding C++ and internal/private headers) is
bound. Remaining `internal`-only surfaces used by a few examples: `ecs_type_str`/
`ecs_get_type` table-type introspection, `EcsTableRecord` fields, component
hooks (`ecs_set_hooks_id` + `EcsTypeHooks`), runtime component creation, the meta
serializer op-array (`EcsMetaOp`), and `ecs_script_*`/`ecs_expr_*` parsing
plumbing.

### Cross-compilation

The vendored C and C3 sources compile for all manifest targets. Verified object
builds: `linux-x64`, `linux-aarch64`, `macos-aarch64`, `windows-x64`
(`c3c compile-only <file> --target <t>`). Final linking for non-native targets
requires the corresponding C runtime/SDK, which is not bundled.

## License

The bindings are provided under the MIT license. Flecs itself is MIT licensed;
its license text is included at `flecs.c3l/c/LICENSE`.
