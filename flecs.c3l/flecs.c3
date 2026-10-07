// flecs
//
// Idiomatic C3 bindings for the Flecs entity component system (Flecs 4.1.6).
//
//     World world;
//     world.init();
//     defer world.fini();
//
//     Entity e = world.entity("player");
//     world.set(Position, e, { .x = 1, .y = 2 });
//     Position* p = world.get(Position, e);
//
//     Query q = world.query_expr("[in] Position, Velocity");
//     Iter it = q.iter(&world);
//     while (it.next())
//     {
//         foreach (idx, ent : it.entities())
//         {
//             Position* pos = it.field(Position, 0);
//             ...
//         }
//     }
//     q.fini();

module flecs;

import flecs::internal;
import std::core::string;
import std::collections::list;
import libc;

// Raw entity/id type used by terms, pair arguments, events, etc.
alias EntityId = internal::EcsEntity;

// Commonly used built-in tags / events, re-exported for convenience.
extern const internal::EcsEntity ECS_ON_ADD @cname("EcsOnAdd");
extern const internal::EcsEntity ECS_ON_REMOVE @cname("EcsOnRemove");
extern const internal::EcsEntity ECS_ON_SET @cname("EcsOnSet");
extern const internal::EcsEntity ECS_ON_START @cname("EcsOnStart");
extern const internal::EcsEntity ECS_PRE_FRAME @cname("EcsPreFrame");
extern const internal::EcsEntity ECS_ON_LOAD @cname("EcsOnLoad");
extern const internal::EcsEntity ECS_POST_LOAD @cname("EcsPostLoad");
extern const internal::EcsEntity ECS_PRE_UPDATE @cname("EcsPreUpdate");
extern const internal::EcsEntity ECS_ON_UPDATE @cname("EcsOnUpdate");
extern const internal::EcsEntity ECS_ON_VALIDATE @cname("EcsOnValidate");
extern const internal::EcsEntity ECS_POST_UPDATE @cname("EcsPostUpdate");
extern const internal::EcsEntity ECS_PRE_STORE @cname("EcsPreStore");
extern const internal::EcsEntity ECS_ON_STORE @cname("EcsOnStore");
extern const internal::EcsEntity ECS_POST_FRAME @cname("EcsPostFrame");
extern const internal::EcsEntity ECS_CHILD_OF @cname("EcsChildOf");
extern const internal::EcsEntity ECS_IS_A @cname("EcsIsA");
extern const internal::EcsEntity ECS_PREFAB @cname("EcsPrefab");
extern const internal::EcsEntity ECS_DISABLED @cname("EcsDisabled");
extern const internal::EcsEntity ECS_WILDCARD @cname("EcsWildcard");
extern const internal::EcsEntity ECS_ANY @cname("EcsAny");
extern const internal::EcsEntity ECS_SINGLETON @cname("EcsSingleton");

// ID flags (compile-time).
const internal::EcsId ECS_PAIR = (internal::EcsId)1 << 63;
const internal::EcsId ECS_AUTO_OVERRIDE = (internal::EcsId)1 << 62;
const internal::EcsId ECS_TOGGLE = (internal::EcsId)1 << 61;
const internal::EcsId ECS_VALUE_PAIR = (internal::EcsId)1 << 60;

// Traits & relationships.
extern const internal::EcsEntity ECS_ON_INSTANTIATE @cname("EcsOnInstantiate");
extern const internal::EcsEntity ECS_OVERRIDE @cname("EcsOverride");
extern const internal::EcsEntity ECS_INHERIT @cname("EcsInherit");
extern const internal::EcsEntity ECS_DONT_INHERIT @cname("EcsDontInherit");
extern const internal::EcsEntity ECS_EXCLUSIVE @cname("EcsExclusive");
extern const internal::EcsEntity ECS_SYMMETRIC @cname("EcsSymmetric");
extern const internal::EcsEntity ECS_ACYCLIC @cname("EcsAcyclic");
extern const internal::EcsEntity ECS_TRAVERSABLE @cname("EcsTraversable");
extern const internal::EcsEntity ECS_TRANSITIVE @cname("EcsTransitive");
extern const internal::EcsEntity ECS_FINAL @cname("EcsFinal");
extern const internal::EcsEntity ECS_INHERITABLE @cname("EcsInheritable");
extern const internal::EcsEntity ECS_REFLEXIVE @cname("EcsReflexive");
extern const internal::EcsEntity ECS_WITH @cname("EcsWith");
extern const internal::EcsEntity ECS_ONE_OF @cname("EcsOneOf");
extern const internal::EcsEntity ECS_CAN_TOGGLE @cname("EcsCanToggle");
extern const internal::EcsEntity ECS_TRAIT @cname("EcsTrait");
extern const internal::EcsEntity ECS_RELATIONSHIP @cname("EcsRelationship");
extern const internal::EcsEntity ECS_TARGET @cname("EcsTarget");
extern const internal::EcsEntity ECS_PAIR_IS_TAG @cname("EcsPairIsTag");
extern const internal::EcsEntity ECS_SLOT_OF @cname("EcsSlotOf");
extern const internal::EcsEntity ECS_DEPENDS_ON @cname("EcsDependsOn");
extern const internal::EcsEntity ECS_MONITOR @cname("EcsMonitor");
extern const internal::EcsEntity ECS_PHASE @cname("EcsPhase");
extern const internal::EcsEntity ECS_ORDERED_CHILDREN @cname("EcsOrderedChildren");

// ---------------------------------------------------------------------------
// Entity
// ---------------------------------------------------------------------------

struct Entity
{
	internal::EcsEntity id;
}

fn bool Entity.is_alive(Entity self, World* world)
{
	return internal::ecs_is_alive(world.raw, self.id);
}

fn ZString Entity.name(Entity self, World* world)
{
	return internal::ecs_get_name(world.raw, self.id);
}

// Name of an entity (internal storage; do not free).
fn ZString World.name(&self, Entity e)
{
	return internal::ecs_get_name(self.raw, e.id);
}

// Name of a raw id (internal storage; do not free).
fn ZString World.name_id(&self, internal::EcsId id)
{
	return internal::ecs_get_name(self.raw, id);
}

// ---------------------------------------------------------------------------
// World
// ---------------------------------------------------------------------------

struct ComponentId
{
	String qname;
	usz size;
	internal::EcsEntity id;
}

struct World
{
	internal::EcsWorld* raw;
	List{ComponentId} components;
}

// Create and initialize a world. Result must be released with World.fini().
fn World create()
{
	World world;
	world.init();
	return world;
}

fn void World.init(&self)
{
	self.raw = internal::ecs_init();
	self.components.init(mem);
}

fn void World.fini(&self)
{
	self.components.free();
	internal::ecs_fini(self.raw);
	self.raw = null;
}

fn bool World.progress(&self, double delta_time = 0.0)
{
	return internal::ecs_progress(self.raw, (float)delta_time);
}

fn void World.quit(&self)
{
	internal::ecs_quit(self.raw);
}

fn void World.set_target_fps(&self, double fps)
{
	internal::ecs_set_target_fps(self.raw, (float)fps);
}

fn void World.set_time_scale(&self, double scale)
{
	internal::ecs_set_time_scale(self.raw, (float)scale);
}

fn void World.set_threads(&self, int threads)
{
	internal::ecs_set_threads(self.raw, threads);
}

fn void World.merge(&self)
{
	internal::ecs_merge(self.raw);
}

// Create a new entity, optionally with a name.
fn Entity World.entity(&self, ZString name = null)
{
	if (name)
	{
		internal::EcsEntityDesc desc = { .name = name };
		return { internal::ecs_entity_init(self.raw, &desc) };
	}
	return { internal::ecs_new(self.raw) };
}

fn Entity World.lookup(&self, ZString path)
{
	return { internal::ecs_lookup(self.raw, path) };
}

// Create an entity tagged as a prefab.
fn Entity World.prefab(&self, ZString name)
{
	Entity e = self.entity(name);
	internal::ecs_add_id(self.raw, e.id, ECS_PREFAB);
	return e;
}

// Create an entity inheriting from a prefab (IsA relationship).
fn Entity World.instantiate(&self, Entity prefab, ZString name = null)
{
	Entity e = self.entity(name);
	internal::ecs_add_id(self.raw, e.id, internal::ecs_make_pair(ECS_IS_A, prefab.id));
	return e;
}

fn void World.destroy(&self, Entity e)
{
	internal::ecs_delete(self.raw, e.id);
}

// ---------------------------------------------------------------------------
// Components
// ---------------------------------------------------------------------------

// Return the component entity for a type, registering it on first use.
// `qname` is the qualified type name and is used as the (collision-free) cache
// key; `symbol` is the simple name used for the registered Flecs entity, so
// query expression identifiers resolve as expected.
fn internal::EcsEntity World.component_id(&self, String qname, String symbol, usz size, usz alignment)
{
	foreach (c : self.components)
	{
		if (c.size == size && c.qname == qname) return c.id;
	}

	// Register with the simple type name (like the C ECS_COMPONENT macro), so
	// query expression identifiers resolve as expected. `qname` is used as the
	// (collision-free) cache key only.
	internal::EcsEntityDesc edesc = {
		.use_low_id = true,
		.name = symbol.zstr_tcopy(),
		.symbol = symbol.zstr_tcopy(),
	};
	internal::EcsEntity entity = internal::ecs_entity_init(self.raw, &edesc);

	internal::EcsComponentDesc cdesc = {
		.entity = entity,
		.type = {
			.size = (internal::EcsSize)size,
			.alignment = (internal::EcsSize)alignment,
		},
	};
	internal::EcsEntity id = internal::ecs_component_init(self.raw, &cdesc);
	self.components.push({ qname, size, id });
	return id;
}

macro internal::EcsEntity World.comp(&self, $Type)
{
	return self.component_id($Type::qname, $Type::name, $Type::size, $Type::alignment);
}

// Register a component explicitly and return its entity.
macro internal::EcsEntity World.register(&self, $Type)
{
	return self.component_id($Type::qname, $Type::name, $Type::size, $Type::alignment);
}

macro bool World.has(&self, $Type, Entity e)
{
	return internal::ecs_has_id(self.raw, e.id, self.comp($Type));
}

macro bool World.owns(&self, $Type, Entity e)
{
	return internal::ecs_owns_id(self.raw, e.id, self.comp($Type));
}

macro void World.add(&self, $Type, Entity e)
{
	internal::ecs_add_id(self.raw, e.id, self.comp($Type));
}

// Add a raw id (component entity or pair) to an entity.
fn void World.add_id(&self, Entity e, internal::EcsEntity id)
{
	internal::ecs_add_id(self.raw, e.id, id);
}

// ---------------------------------------------------------------------------
// Pairs, entities & misc helpers
// ---------------------------------------------------------------------------

const internal::EcsId ECS_COMPONENT_MASK = ~((internal::EcsId)0xFF << 60);

fn void World.add_pair(&self, Entity e, internal::EcsEntity rel, internal::EcsEntity tgt)
{
	internal::ecs_add_id(self.raw, e.id, internal::ecs_make_pair(rel, tgt));
}

fn void World.remove_pair(&self, Entity e, internal::EcsEntity rel, internal::EcsEntity tgt)
{
	internal::ecs_remove_id(self.raw, e.id, internal::ecs_make_pair(rel, tgt));
}

fn bool World.has_pair(&self, Entity e, internal::EcsEntity rel, internal::EcsEntity tgt)
{
	return internal::ecs_has_id(self.raw, e.id, internal::ecs_make_pair(rel, tgt));
}

// Does the entity have any pair with `rel` (wildcard target)?
fn bool World.has_pair_rel(&self, Entity e, internal::EcsEntity rel)
{
	return internal::ecs_has_id(self.raw, e.id, internal::ecs_make_pair(rel, ECS_WILDCARD));
}

fn Entity World.new_pair(&self, internal::EcsEntity rel, internal::EcsEntity tgt)
{
	return { internal::ecs_new_w_id(self.raw, internal::ecs_make_pair(rel, tgt)) };
}

fn internal::EcsEntity World.pair_first(&self, internal::EcsId pair)
{
	return internal::ecs_get_alive(self.raw, (pair & ECS_COMPONENT_MASK) >> 32);
}

fn internal::EcsEntity World.pair_second(&self, internal::EcsId pair)
{
	return internal::ecs_get_alive(self.raw, pair & 0xFFFFFFFF);
}

macro World.get_pair(&self, $Type, Entity e, internal::EcsEntity tgt)
{
	return ($Type*)internal::ecs_get_id(self.raw, e.id, internal::ecs_make_pair(self.comp($Type), tgt));
}

macro void World.set_pair(&self, $Type, Entity e, internal::EcsEntity tgt, #value) @safemacro
{
	$Type v = #value;
	internal::ecs_set_id(self.raw, e.id, internal::ecs_make_pair(self.comp($Type), tgt),
		(internal::EcsSize)$Type::size, &v);
}

macro World.get_pair_second(&self, $Type, Entity e, internal::EcsEntity rel)
{
	return ($Type*)internal::ecs_get_id(self.raw, e.id, internal::ecs_make_pair(rel, self.comp($Type)));
}

macro void World.set_pair_second(&self, $Type, Entity e, internal::EcsEntity rel, #value) @safemacro
{
	$Type v = #value;
	internal::ecs_set_id(self.raw, e.id, internal::ecs_make_pair(rel, self.comp($Type)),
		(internal::EcsSize)$Type::size, &v);
}

// --- entities & misc -------------------------------------------------------

fn Entity World.lookup_child(&self, Entity parent, ZString name)
{
	return { internal::ecs_lookup_child(self.raw, parent.id, name) };
}

// Iterate the children of an entity (ChildOf). Free-standing iterators must be
// fully iterated (or `Iter.fini` called).
fn Iter World.children(&self, Entity parent)
{
	return { internal::ecs_children(self.raw, parent.id) };
}

// Hierarchical path of an entity. Free the result with `flecs::free_str`.
fn String World.path(&self, Entity e)
{
	ZString s = internal::ecs_get_path_w_sep(self.raw, 0, e.id, ".", null);
	return s ? s.str_view() : "";
}

// String representation of an id. Free the result with `flecs::free_str`.
fn String World.id_str(&self, internal::EcsId id)
{
	ZString s = internal::ecs_id_str(self.raw, id);
	return s ? s.str_view() : "";
}

fn void World.remove_id(&self, Entity e, internal::EcsId id)
{
	internal::ecs_remove_id(self.raw, e.id, id);
}

fn bool World.has_id(&self, Entity e, internal::EcsId id)
{
	return internal::ecs_has_id(self.raw, e.id, id);
}

fn int World.count(&self, internal::EcsId id)
{
	return internal::ecs_count_id(self.raw, id);
}

fn void World.run_system(&self, Entity system, double delta_time = 0.0)
{
	internal::ecs_run(self.raw, system.id, (float)delta_time, null);
}

// Create an entity initialized with `value`.
macro Entity World.insert(&self, $Type, #value) @safemacro
{
	$Type v = #value;
	Entity e = self.entity();
	internal::ecs_set_id(self.raw, e.id, self.comp($Type), (internal::EcsSize)$Type::size, &v);
	return e;
}

macro void World.remove(&self, $Type, Entity e)
{
	internal::ecs_remove_id(self.raw, e.id, self.comp($Type));
}

macro World.get(&self, $Type, Entity e)
{
	return ($Type*)internal::ecs_get_id(self.raw, e.id, self.comp($Type));
}

macro World.get_mut(&self, $Type, Entity e)
{
	return ($Type*)internal::ecs_get_mut_id(self.raw, e.id, self.comp($Type));
}

macro World.ensure(&self, $Type, Entity e)
{
	return ($Type*)internal::ecs_ensure_id(self.raw, e.id, self.comp($Type), (internal::EcsSize)$Type::size);
}

macro void World.set(&self, $Type, Entity e, #value) @safemacro
{
	$Type v = #value;
	internal::ecs_set_id(self.raw, e.id, self.comp($Type), (internal::EcsSize)$Type::size, &v);
}

macro void World.modified(&self, $Type, Entity e)
{
	internal::ecs_modified_id(self.raw, e.id, self.comp($Type));
}

// ---------------------------------------------------------------------------
// Queries & iteration
// ---------------------------------------------------------------------------

alias InOut = internal::EcsInOutKind;
alias Oper = internal::EcsOperKind;

// Term reference flags (combine onto Term.src/first/second .id).
const internal::EcsEntity ECS_SELF = (internal::EcsEntity)1 << 63;
const internal::EcsEntity ECS_UP = (internal::EcsEntity)1 << 62;
const internal::EcsEntity ECS_TRAV = (internal::EcsEntity)1 << 61;
const internal::EcsEntity ECS_CASCADE = (internal::EcsEntity)1 << 60;
const internal::EcsEntity ECS_DESC = (internal::EcsEntity)1 << 59;
const internal::EcsEntity ECS_IS_VARIABLE = (internal::EcsEntity)1 << 58;
const internal::EcsEntity ECS_IS_ENTITY = (internal::EcsEntity)1 << 57;
const internal::EcsEntity ECS_IS_NAME = (internal::EcsEntity)1 << 56;

// Query flags (combine onto QueryOptions.flags).
const internal::EcsFlags32 ECS_QUERY_MATCH_PREFAB = 1 << 1;
const internal::EcsFlags32 ECS_QUERY_MATCH_DISABLED = 1 << 2;
const internal::EcsFlags32 ECS_QUERY_MATCH_EMPTY_TABLES = 1 << 3;
const internal::EcsFlags32 ECS_QUERY_DETECT_CHANGES = 1 << 8;

// Reference to an entity, variable, or name in a term.
struct TermRef
{
	internal::EcsEntity id;
	ZString name;
}

// A query term. `id` is a component entity (`world.comp(T)`), a pair
// (`world.pair(rel, tgt)`), or a variable/name via `first`/`second`/`src`.
struct Term
{
	internal::EcsEntity id;
	InOut inout;
	Oper oper;
	internal::EcsEntity trav;
	TermRef src;
	TermRef first;
	TermRef second;
}

// Options for `World.query_opts`.
struct QueryOptions
{
	ZString expr; // if set, overrides `terms`
	internal::EcsFlags32 flags;
	internal::EcsQueryCacheKind cache_kind;
	internal::EcsEntity order_by;
	internal::EcsOrderByAction order_by_callback;
	internal::EcsId group_by;
	internal::EcsGroupByAction group_by_callback;
	internal::EcsGroupCreateAction on_group_create;
	internal::EcsGroupDeleteAction on_group_delete;
	void* group_by_ctx;
}

struct Query
{
	internal::EcsQuery* raw;
}

// Create a pair id for use as a term id (e.g. `world.pair(flecs::ECS_CHILD_OF, e.id)`).
fn internal::EcsEntity World.pair(&self, internal::EcsEntity rel, internal::EcsEntity tgt)
{
	return internal::ecs_make_pair(rel, tgt);
}

// Fill a query descriptor's terms from `terms`.
fn void fill_terms(internal::EcsQueryDesc* desc, Term[] terms)
{
	for (int i = 0; i < terms.len; i++)
	{
		Term t = terms[i];
		internal::EcsTerm* dt = &desc.terms[i];
		dt.id = t.id;
		dt.inout = (short)t.inout;
		dt.oper = (short)t.oper;
		dt.trav = t.trav;
		dt.src.id = t.src.id;
		dt.src.name = t.src.name;
		dt.first.id = t.first.id;
		dt.first.name = t.first.name;
		dt.second.id = t.second.id;
		dt.second.name = t.second.name;
	}
}

// Create a query from term descriptors.
fn Query World.query(&self, Term[] terms)
{
	internal::EcsQueryDesc desc = {};
	fill_terms(&desc, terms);
	return { internal::ecs_query_init(self.raw, &desc) };
}

// Create a query from a Flecs query expression string.
fn Query World.query_expr(&self, ZString expr)
{
	internal::EcsQueryDesc desc = { .expr = expr };
	return { internal::ecs_query_init(self.raw, &desc) };
}

// Create a query with full options (flags, caching, ordering, grouping).
fn Query World.query_opts(&self, Term[] terms, QueryOptions opts)
{
	internal::EcsQueryDesc desc = {};
	if (opts.expr)
	{
		desc.expr = opts.expr;
	}
	else
	{
		fill_terms(&desc, terms);
	}
	desc.flags = opts.flags;
	desc.cache_kind = opts.cache_kind;
	desc.order_by = opts.order_by;
	desc.order_by_callback = opts.order_by_callback;
	desc.group_by = opts.group_by;
	desc.group_by_callback = opts.group_by_callback;
	desc.on_group_create = opts.on_group_create;
	desc.on_group_delete = opts.on_group_delete;
	desc.group_by_ctx = opts.group_by_ctx;
	return { internal::ecs_query_init(self.raw, &desc) };
}

fn void Query.fini(&self)
{
	internal::ecs_query_fini(self.raw);
}

fn bool Query.changed(&self)
{
	return internal::ecs_query_changed(self.raw);
}

fn int Query.find_var(&self, ZString name) => internal::ecs_query_find_var(self.raw, name);
fn internal::EcsQueryGroupInfo* Query.group_info(&self, ulong group_id) => internal::ecs_query_get_group_info(self.raw, group_id);
fn void* Query.group_ctx(&self, ulong group_id) => internal::ecs_query_get_group_ctx(self.raw, group_id);
fn int Query.match_count(&self) => internal::ecs_query_match_count(self.raw);

struct Iter
{
	internal::EcsIter raw;
}

fn Iter Query.iter(&self, World* world)
{
	return { internal::ecs_query_iter(world.raw, self.raw) };
}

macro Iter World.each(&self, $Type)
{
	return { internal::ecs_each_id(self.raw, self.comp($Type)) };
}

fn bool Iter.next(&self)
{
	// Empty iterators (e.g. ecs_children of a leaf) have a NULL `next`.
	if (!self.raw.next) return false;
	return internal::ecs_iter_next(&self.raw);
}

fn int Iter.count(&self)
{
	return self.raw.count;
}

fn double Iter.delta_time(&self)
{
	return (double)self.raw.delta_time;
}

fn internal::EcsEntity[] Iter.entities(&self)
{
	return self.raw.entities[0:self.raw.count];
}

fn Entity Iter.entity_at(&self, int index)
{
	return { self.raw.entities[index] };
}

macro Iter.field(&self, $Type, int index)
{
	return ($Type*)internal::ecs_field_w_size(&self.raw, (internal::EcsSize)$Type::size, (ichar)index);
}

macro EcsId Iter.field_id(&self, int index)
{
	return internal::ecs_field_id(&self.raw, (ichar)index);
}

fn void Iter.fini(&self)
{
	internal::ecs_iter_fini(&self.raw);
}

fn ZString Iter.name(&self, internal::EcsId id) => internal::ecs_get_name(self.raw.world, id);
fn internal::EcsEntity Iter.get_var(&self, int var_id) => internal::ecs_iter_get_var(&self.raw, var_id);
fn void Iter.set_var(&self, int var_id, internal::EcsEntity e) => internal::ecs_iter_set_var(&self.raw, var_id, e);
fn bool Iter.is_true(&self) => internal::ecs_iter_is_true(&self.raw);
fn bool Iter.changed(&self) => internal::ecs_iter_changed(&self.raw);
fn void Iter.skip(&self) => internal::ecs_iter_skip(&self.raw);
fn ulong Iter.group(&self) => internal::ecs_iter_get_group(&self.raw);
fn void Iter.set_group(&self, ulong group_id) => internal::ecs_iter_set_group(&self.raw, group_id);

// Serialize the iterator to JSON. Free with `flecs::free_str`.
fn String Iter.to_json(&self)
{
	ZString s = internal::ecs_iter_to_json(&self.raw, null);
	return s ? s.str_view() : "";
}

// User context attached to a reflected system/observer callback (set via
// `SystemOptions.ctx` / `ObserverOptions.ctx`). Returns null if none.
fn void* Iter.ctx(&self)
{
	CallbackCtx* c = (CallbackCtx*)self.raw.ctx;
	return c ? c.user_ctx : null;
}

// ---------------------------------------------------------------------------
// Systems & observers
//
// Reflected API: callbacks take the component slices they use (plus an
// optional leading `Iter*`). The query is inferred from the parameter types.
// All inferred terms are `inout`; pass an explicit query string to set
// `[in]`/`[out]`.
//
//     fn void move(Position[] pos, Velocity[] vel) { ... }
//     world.system("Move", &move);
//
// The raw iterator-based API is available as `system_iter`/`observer_iter`.
// ---------------------------------------------------------------------------

alias SystemCallback = fn void(Iter* it);

fn void system_trampoline(internal::EcsIter* raw)
{
	SystemCallback cb = (SystemCallback)raw.ctx;
	Iter it = { *raw };
	cb(&it);
}

// Register a system whose callback takes the iterator directly.
fn Entity World.system_iter(&self, ZString name, SystemCallback callback, ZString expr,
	internal::EcsEntity phase = 0)
{
	internal::EcsSystemDesc desc = {
		.query = { .expr = expr },
		.callback = &system_trampoline,
		.ctx = (void*)callback,
		.phase = phase ? phase : ECS_ON_UPDATE,
	};
	internal::EcsEntity e = internal::ecs_system_init(self.raw, &desc);
	if (name) internal::ecs_set_name(self.raw, e, name);
	return { e };
}

alias ObserverCallback = fn void(Iter* it);

fn void observer_trampoline(internal::EcsIter* raw)
{
	ObserverCallback cb = (ObserverCallback)raw.ctx;
	Iter it = { *raw };
	cb(&it);
}

// Register an observer whose callback takes the iterator directly.
fn Entity World.observer_iter(&self, ZString name, internal::EcsEntity event,
	ObserverCallback callback, ZString expr)
{
	internal::EcsObserverDesc desc = {
		.query = { .expr = expr },
		.callback = &observer_trampoline,
		.ctx = (void*)callback,
	};
	desc.events[0] = event;
	internal::EcsEntity e = internal::ecs_observer_init(self.raw, &desc);
	if (name) internal::ecs_set_name(self.raw, e, name);
	return { e };
}

fn Entity World.observer_iter_existing(&self, ZString name, internal::EcsEntity event,
	ObserverCallback callback, ZString expr)
{
	internal::EcsObserverDesc desc = {
		.query = { .expr = expr },
		.callback = &observer_trampoline,
		.ctx = (void*)callback,
		.yield_existing = true,
	};
	desc.events[0] = event;
	internal::EcsEntity e = internal::ecs_observer_init(self.raw, &desc);
	if (name) internal::ecs_set_name(self.raw, e, name);
	return { e };
}

// --- reflection helpers ---------------------------------------------------

macro bool @is_iter_param($Callback, $i)
{
	var $Pt = $Callback::params[$i].type;
	$switch $Pt::kind:
		$case POINTER:
			return $Pt::inner == Iter;
		$default:
			return false;
	$endswitch
}

macro bool @has_iter_param($Callback)
{
	$if $Callback::params.len > 0:
		return @is_iter_param($Callback, 0);
	$else
		return false;
	$endif
}

// Build a single callback argument for parameter `$i` from the iterator.
macro @sys_arg(#raw, #itv, $Callback, $i)
{
	var $Pt = $Callback::params[$i].type;
	$if @is_iter_param($Callback, $i):
		return &#itv;
	$endif
	var $has_iter = @has_iter_param($Callback);
	var $field = $i - ($has_iter ? 1 : 0);
	$switch $Pt::kind:
		$case SLICE:
			var $El = $Pt::inner;
			return ((($El*)internal::ecs_field_w_size(#raw, (internal::EcsSize)$El::size, (ichar)$field)))[0:#raw.count];
		$case POINTER:
			var $El = $Pt::inner;
			return ($El*)internal::ecs_field_w_size(#raw, (internal::EcsSize)$El::size, (ichar)$field);
		$default:
			$error "flecs callback parameters must be component slices/pointers or Iter*";
	$endswitch
}

// Carries the reflected callback pointer plus an optional user context into
// `desc.ctx`. Flecs frees it via `ctx_free` when the system/observer is fini'd.
struct CallbackCtx
{
	void* callback;
	void* user_ctx;
}

fn void callback_ctx_free(void* ctx)
{
	mem::free(ctx);
}

fn CallbackCtx* callback_ctx_new(void* callback, void* user_ctx)
{
	CallbackCtx* c = (CallbackCtx*)mem::malloc(CallbackCtx::size);
	c.callback = callback;
	c.user_ctx = user_ctx;
	return c;
}

fn void callback_adapter(internal::EcsIter* raw) <Callback>
{
	CallbackCtx* c = (CallbackCtx*)raw.ctx;
	Callback cb = (Callback)c.callback;
	Iter it_val = { *raw };
	$if Callback::params.len == 0:
		cb();
	$else
		var $Ps = Callback::param_struct;
		$Ps ps = {};
		$foreach $i, $m : $Ps::members:
			ps.$m = @sys_arg(raw, it_val, Callback, $i);
		$endforeach
		cb(...ps);
	$endif
}

// Register/return a component id for every component parameter of `Callback`
// into `#ids`, indexed by field (accounting for an optional leading Iter*).
macro @collect_ids(#w, $Callback, #ids)
{
	var $has_iter = @has_iter_param($Callback);
	$foreach $i, $param : $Callback::params:
		$if !@is_iter_param($Callback, $i):
			var $field = $i - ($has_iter ? 1 : 0);
			var $Pt = $param.type;
			$switch $Pt::kind:
				$case SLICE:
					var $El = $Pt::inner;
					#ids[$field] = #w.component_id($El::qname, $El::name, $El::size, $El::alignment);
				$case POINTER:
					var $El = $Pt::inner;
					#ids[$field] = #w.component_id($El::qname, $El::name, $El::size, $El::alignment);
				$default:
					$error "flecs callback parameters must be component slices/pointers or Iter*";
			$endswitch
		$endif
	$endforeach
}

// The callback is passed as `void*` rather than a `Callback`-typed parameter.
// Passing the function pointer directly triggers a c3c "implicitly casting
// 'fn ...' to 'fn ...'" error when built via a project `c3c test`, even though
// the types are identical. The adapter casts `raw.ctx` back to `Callback`.
fn internal::EcsEntity system(World* w, ZString name, void* cb, ZString expr = null,
	internal::EcsEntity phase = 0, Term[] terms = {}, void* user_ctx = null) <Callback>
{
	internal::EcsSystemDesc desc = {};
	desc.phase = phase ? phase : ECS_ON_UPDATE;

	internal::EcsEntity[32] ids = {};
	@collect_ids(w, Callback, ids);

	if (terms.len > 0)
	{
		fill_terms(&desc.query, terms);
	}
	else if (expr)
	{
		desc.query.expr = expr;
	}
	else
	{
		$foreach $i, $param : Callback::params:
			$if !@is_iter_param(Callback, $i):
				var $field = $i - (@has_iter_param(Callback) ? 1 : 0);
				desc.query.terms[$field].id = ids[$field];
			$endif
		$endforeach
	}

	desc.callback = &callback_adapter{Callback};
	desc.ctx = callback_ctx_new(cb, user_ctx);
	desc.ctx_free = &callback_ctx_free;
	internal::EcsEntity e = internal::ecs_system_init(w.raw, &desc);
	if (name) internal::ecs_set_name(w.raw, e, name);
	return e;
}

fn internal::EcsEntity observer(World* w, ZString name, internal::EcsEntity event,
	void* cb, Term[] terms = {}, ZString expr = null, bool yield_existing = false,
	void* user_ctx = null) <Callback>
{
	internal::EcsObserverDesc desc = {};
	desc.events[0] = event;
	desc.yield_existing = yield_existing;

	internal::EcsEntity[32] ids = {};
	@collect_ids(w, Callback, ids);

	if (terms.len > 0)
	{
		fill_terms(&desc.query, terms);
	}
	else if (expr)
	{
		desc.query.expr = expr;
	}
	else
	{
		$foreach $i, $param : Callback::params:
			$if !@is_iter_param(Callback, $i):
				var $field = $i - (@has_iter_param(Callback) ? 1 : 0);
				desc.query.terms[$field].id = ids[$field];
			$endif
		$endforeach
	}

	desc.callback = &callback_adapter{Callback};
	desc.ctx = callback_ctx_new(cb, user_ctx);
	desc.ctx_free = &callback_ctx_free;
	internal::EcsEntity e = internal::ecs_observer_init(w.raw, &desc);
	if (name) internal::ecs_set_name(w.raw, e, name);
	return e;
}

// Register a system with multiple observer events (e.g. OnAdd + OnRemove).
fn internal::EcsEntity observer_multi(World* w, ZString name, EntityId[] events,
	void* cb, Term[] terms = {}, ZString expr = null, bool yield_existing = false,
	void* user_ctx = null) <Callback>
{
	internal::EcsObserverDesc desc = {};
	for (int i = 0; i < events.len; i++) desc.events[i] = events[i];
	desc.yield_existing = yield_existing;

	internal::EcsEntity[32] ids = {};
	@collect_ids(w, Callback, ids);

	if (terms.len > 0)
	{
		fill_terms(&desc.query, terms);
	}
	else if (expr)
	{
		desc.query.expr = expr;
	}
	else
	{
		$foreach $i, $param : Callback::params:
			$if !@is_iter_param(Callback, $i):
				var $field = $i - (@has_iter_param(Callback) ? 1 : 0);
				desc.query.terms[$field].id = ids[$field];
			$endif
		$endforeach
	}

	desc.callback = &callback_adapter{Callback};
	desc.ctx = callback_ctx_new(cb, user_ctx);
	desc.ctx_free = &callback_ctx_free;
	internal::EcsEntity e = internal::ecs_observer_init(w.raw, &desc);
	if (name) internal::ecs_set_name(w.raw, e, name);
	return e;
}

// Register a system; query inferred from callback parameters unless `terms` is
// given. `phase` defaults to `flecs::ECS_ON_UPDATE`.
macro Entity World.system(&self, ZString name, callback, internal::EcsEntity phase = 0, Term[] terms = {})
{
	return { system{$Typeof(callback)}(self, name, (void*)callback, null, phase, terms) };
}

// Register a system with an explicit query expression.
macro Entity World.system_expr(&self, ZString name, callback, ZString expr, internal::EcsEntity phase = 0)
{
	return { system{$Typeof(callback)}(self, name, (void*)callback, expr, phase, {}) };
}

// Register an observer for `event`; query inferred from callback parameters
// unless `terms` is given.
macro Entity World.observer(&self, ZString name, internal::EcsEntity event, callback, Term[] terms = {})
{
	return { observer{$Typeof(callback)}(self, name, event, (void*)callback, terms, null, false) };
}

// Register an observer with an explicit query expression.
macro Entity World.observer_expr(&self, ZString name, internal::EcsEntity event, callback, ZString expr)
{
	return { observer{$Typeof(callback)}(self, name, event, (void*)callback, {}, expr, false) };
}

// Register an observer matching existing entities.
macro Entity World.observer_existing(&self, ZString name, internal::EcsEntity event, callback, Term[] terms = {})
{
	return { observer{$Typeof(callback)}(self, name, event, (void*)callback, terms, null, true) };
}

// Register an observer for multiple events (e.g. `ECS_ON_ADD` + `ECS_ON_REMOVE`).
macro Entity World.observer_events(&self, ZString name, EntityId[] events, callback, Term[] terms = {})
{
	return { observer_multi{$Typeof(callback)}(self, name, events, (void*)callback, terms) };
}

// Register an observer with a user context (retrieve with `Iter.ctx()`).
macro Entity World.observer_ctx(&self, ZString name, internal::EcsEntity event, callback, void* ctx,
	Term[] terms = {})
{
	return { observer{$Typeof(callback)}(self, name, event, (void*)callback, terms, null, false, ctx) };
}

// --- system options --------------------------------------------------------

struct SystemOptions
{
	internal::EcsEntity phase;
	bool immediate;
	bool multi_threaded;
	float interval;
	int rate;
	internal::EcsEntity tick_source;
	void* ctx;
	internal::EcsRunAction run;
	ZString expr;
	Term[] terms;
	internal::EcsEntity order_by;
	internal::EcsOrderByAction order_by_callback;
}

fn internal::EcsEntity system_full(World* w, ZString name, void* cb, SystemOptions opts) <Callback>
{
	internal::EcsSystemDesc desc = {};
	desc.phase = opts.phase ? opts.phase : ECS_ON_UPDATE;
	desc.immediate = opts.immediate;
	desc.multi_threaded = opts.multi_threaded;
	desc.interval = opts.interval;
	desc.rate = opts.rate;
	desc.tick_source = opts.tick_source;
	desc.run = opts.run;
	desc.query.order_by = opts.order_by;
	desc.query.order_by_callback = opts.order_by_callback;

	internal::EcsEntity[32] ids = {};
	@collect_ids(w, Callback, ids);

	if (opts.terms.len > 0)
	{
		fill_terms(&desc.query, opts.terms);
	}
	else if (opts.expr)
	{
		desc.query.expr = opts.expr;
	}
	else
	{
		$foreach $i, $param : Callback::params:
			$if !@is_iter_param(Callback, $i):
				var $field = $i - (@has_iter_param(Callback) ? 1 : 0);
				desc.query.terms[$field].id = ids[$field];
			$endif
		$endforeach
	}

	desc.callback = &callback_adapter{Callback};
	desc.ctx = callback_ctx_new(cb, opts.ctx);
	desc.ctx_free = &callback_ctx_free;
	internal::EcsEntity e = internal::ecs_system_init(w.raw, &desc);
	if (name) internal::ecs_set_name(w.raw, e, name);
	return e;
}

// Register a system with full options (phase, immediate, threading, interval,
// rate, tick source, user context, custom run callback, explicit query).
macro Entity World.system_opts(&self, ZString name, callback, SystemOptions opts)
{
	return { system_full{$Typeof(callback)}(self, name, (void*)callback, opts) };
}

// Register a system with a user context (retrieve with `Iter.ctx()`).
macro Entity World.system_ctx(&self, ZString name, callback, void* ctx, internal::EcsEntity phase = 0)
{
	SystemOptions opts = { .phase = phase, .ctx = ctx };
	return { system_full{$Typeof(callback)}(self, name, (void*)callback, opts) };
}

// --- events ----------------------------------------------------------------

fn void World.emit(&self, internal::EcsEntity event, Entity entity)
{
	internal::EcsEventDesc desc = { .event = event, .entity = entity.id };
	internal::ecs_emit(self.raw, &desc);
}

fn void World.emit_ids(&self, internal::EcsEntity event, Entity entity, internal::EcsId[] ids)
{
	internal::EcsType t = { .array = ids.len > 0 ? &ids[0] : null, .count = (int)ids.len };
	internal::EcsEventDesc desc = { .event = event, .entity = entity.id, .ids = &t };
	internal::ecs_emit(self.raw, &desc);
}

fn void World.emit_param(&self, internal::EcsEntity event, Entity entity, void* param)
{
	internal::EcsEventDesc desc = { .event = event, .entity = entity.id, .param = param };
	internal::ecs_emit(self.raw, &desc);
}

fn void World.enqueue(&self, internal::EcsEntity event, Entity entity)
{
	internal::EcsEventDesc desc = { .event = event, .entity = entity.id };
	internal::ecs_enqueue(self.raw, &desc);
}

fn void World.enqueue_param(&self, internal::EcsEntity event, Entity entity, void* param)
{
	internal::EcsEventDesc desc = { .event = event, .entity = entity.id, .param = param };
	internal::ecs_enqueue(self.raw, &desc);
}

fn void World.enqueue_ids(&self, internal::EcsEntity event, Entity entity, internal::EcsId[] ids)
{
	internal::EcsType t = { .array = ids.len > 0 ? &ids[0] : null, .count = (int)ids.len };
	internal::EcsEventDesc desc = { .event = event, .entity = entity.id, .ids = &t };
	internal::ecs_enqueue(self.raw, &desc);
}

// ---------------------------------------------------------------------------
// Timers & staging
// ---------------------------------------------------------------------------

fn void World.set_interval(&self, Entity tick_source, double interval)
{
	internal::ecs_set_interval(self.raw, tick_source.id, (float)interval);
}

fn void World.set_timeout(&self, Entity tick_source, double timeout)
{
	internal::ecs_set_timeout(self.raw, tick_source.id, (float)timeout);
}

fn void World.set_rate(&self, Entity tick_source, int rate, Entity source = { 0 })
{
	internal::ecs_set_rate(self.raw, tick_source.id, rate, source.id);
}

fn void World.set_tick_source(&self, Entity system, Entity tick_source)
{
	internal::ecs_set_tick_source(self.raw, system.id, tick_source.id);
}

fn void World.start_timer(&self, Entity tick_source)
{
	internal::ecs_start_timer(self.raw, tick_source.id);
}

fn void World.stop_timer(&self, Entity tick_source)
{
	internal::ecs_stop_timer(self.raw, tick_source.id);
}

fn void World.reset_timer(&self, Entity tick_source)
{
	internal::ecs_reset_timer(self.raw, tick_source.id);
}

fn void World.randomize_timers(&self)
{
	internal::ecs_randomize_timers(self.raw);
}

fn bool World.defer_begin(&self)
{
	return internal::ecs_defer_begin(self.raw);
}

fn bool World.defer_end(&self)
{
	return internal::ecs_defer_end(self.raw);
}

fn EcsEntity World.get_pipeline(&self)
{
	return internal::ecs_get_pipeline(self.raw);
}

fn void World.set_pipeline(&self, Entity pipeline)
{
	internal::ecs_set_pipeline(self.raw, pipeline.id);
}

fn void World.run_pipeline(&self, Entity pipeline, double delta_time)
{
	internal::ecs_run_pipeline(self.raw, pipeline.id, (float)delta_time);
}

// ---------------------------------------------------------------------------
// JSON serialization
//
// Strings returned by the serializers are heap allocated by Flecs. Release
// them with `flecs::free_str()`.
// ---------------------------------------------------------------------------

fn String World.to_json(&self, bool include_builtin = false)
{
	internal::EcsWorldToJsonDesc desc = { .serialize_builtin = include_builtin };
	ZString s = internal::ecs_world_to_json(self.raw, &desc);
	if (!s) return "";
	return s.str_view();
}

fn String World.entity_to_json(&self, Entity e, bool values = true)
{
	internal::EcsEntityToJsonDesc desc = { .serialize_values = values };
	ZString s = internal::ecs_entity_to_json(self.raw, e.id, &desc);
	if (!s) return "";
	return s.str_view();
}

// Returns true on success.
fn bool World.from_json(&self, ZString json)
{
	return internal::ecs_world_from_json(self.raw, json, null) != null;
}

// Returns true on success.
fn bool World.entity_from_json(&self, Entity e, ZString json)
{
	return internal::ecs_entity_from_json(self.raw, e.id, json, null) != null;
}

fn void free_str(String s)
{
	libc::free(s.ptr);
}

// Serialize a value of a reflected `type` to JSON. Free with `free_str`.
fn String World.ptr_to_json(&self, internal::EcsEntity type, void* data)
{
	ZString s = internal::ecs_ptr_to_json(self.raw, type, data);
	return s ? s.str_view() : "";
}

// Serialize a value of a reflected `type` to an expression string.
fn String World.ptr_to_expr(&self, internal::EcsEntity type, void* data)
{
	ZString s = internal::ecs_ptr_to_expr(self.raw, type, data);
	return s ? s.str_view() : "";
}

// Serialize `count` values of a reflected `type` to JSON.
fn String World.array_to_json(&self, internal::EcsEntity type, void* data, int count)
{
	ZString s = internal::ecs_array_to_json(self.raw, type, data, count);
	return s ? s.str_view() : "";
}

// ---------------------------------------------------------------------------
// Meta (reflection)
// ---------------------------------------------------------------------------

macro bool @is_primitive_type($Type)
{
	var $Ty = $Type;
	$switch $Ty::kind:
		$case BOOL:
		$case SIGNED_INT:
		$case UNSIGNED_INT:
		$case FLOAT:
			return true;
		$case SLICE:
			return $Ty::inner == char;
		$case POINTER:
			return $Ty::inner == char;
		$case TYPEDEF:
			return @is_primitive_type($Ty::inner);
		$default:
			return false;
	$endswitch
}

macro internal::EcsEntity @primitive_type($Type)
{
	var $Ty = $Type;
	$switch $Ty::kind:
		$case BOOL:
			return internal::ECS_TYPE_BOOL;
		$case SIGNED_INT:
			$switch $Ty::size:
				$case 1: return internal::ECS_TYPE_I8;
				$case 2: return internal::ECS_TYPE_I16;
				$case 4: return internal::ECS_TYPE_I32;
				$default: return internal::ECS_TYPE_I64;
			$endswitch
		$case UNSIGNED_INT:
			$switch $Ty::size:
				$case 1: return internal::ECS_TYPE_U8;
				$case 2: return internal::ECS_TYPE_U16;
				$case 4: return internal::ECS_TYPE_U32;
				$default: return internal::ECS_TYPE_U64;
			$endswitch
		$case FLOAT:
			$if $Ty::size == 4:
				return internal::ECS_TYPE_F32;
			$else
				return internal::ECS_TYPE_F64;
			$endif
		$case SLICE:
		$case POINTER:
			return internal::ECS_TYPE_STRING;
		$case TYPEDEF:
			return @primitive_type($Ty::inner);
		$default:
			return 0;
	$endswitch
}

// Map a reflected member type to a Flecs meta type entity, recursively
// registering nested structs/enums and fixed arrays.
macro internal::EcsEntity @member_type_id(#w, $Mt)
{
	$if $Mt == Entity:
		return internal::ECS_TYPE_ENTITY;
	$endif
	$if @is_primitive_type($Mt):
		return @primitive_type($Mt);
	$endif
	$switch $Mt::kind:
		$case STRUCT:
			return #w.struct_meta($Mt);
		$case ENUM:
			return #w.enum_meta($Mt);
		$case ARRAY:
			var $El = $Mt::inner;
			internal::EcsArrayDesc ad = { .type = @member_type_id(#w, $El), .count = (int)$Mt::len };
			return internal::ecs_array_init(#w.raw, &ad);
		$default:
			return #w.component_id($Mt::qname, $Mt::name, $Mt::size, $Mt::alignment);
	$endswitch
}

// Register reflection data for a struct type from C3 type reflection. Nested
// structs/enums and fixed arrays are registered recursively; `EcsEntity`
// members map to the built-in entity type.
macro internal::EcsEntity World.struct_meta(&self, $Type)
{
	internal::EcsStructDesc desc = {};
	desc.entity = self.comp($Type);
	desc.create_member_entities = true;
	$foreach $i, $member : $Type::members:
		desc.members[$i].name = $member.name.zstr_tcopy();
		desc.members[$i].offset = (int)$member.offset;
		desc.members[$i].use_offset = true;
		desc.members[$i].type = @member_type_id(self, $member.type);
	$endforeach
	return internal::ecs_struct_init(self.raw, &desc);
}

// Per-member metadata overrides for `struct_meta_full`.
struct MemberDesc
{
	String name;
	internal::EcsEntity unit;
	internal::EcsMemberValueRange range;
	internal::EcsMemberValueRange error_range;
	internal::EcsMemberValueRange warning_range;
}

// Register struct reflection, applying per-member unit/range metadata.
macro internal::EcsEntity World.struct_meta_full(&self, $Type, MemberDesc[] members)
{
	internal::EcsStructDesc desc = {};
	desc.entity = self.comp($Type);
	desc.create_member_entities = true;
	$foreach $i, $member : $Type::members:
		desc.members[$i].name = $member.name.zstr_tcopy();
		desc.members[$i].offset = (int)$member.offset;
		desc.members[$i].use_offset = true;
		desc.members[$i].type = @member_type_id(self, $member.type);
	$endforeach
	for (int i = 0; i < members.len; i++)
	{
		$foreach $j, $member : $Type::members:
			if (members[i].name == $member.name)
			{
				desc.members[$j].unit = members[i].unit;
				desc.members[$j].range = members[i].range;
				desc.members[$j].error_range = members[i].error_range;
				desc.members[$j].warning_range = members[i].warning_range;
			}
		$endforeach
	}
	return internal::ecs_struct_init(self.raw, &desc);
}

// Register reflection for an enum with explicit constant names (C3 enum members
// are uppercased, so pass the original casing here).
macro internal::EcsEntity World.enum_meta_named(&self, $Type, String[] names)
{
	internal::EcsEnumDesc desc = {};
	desc.entity = self.comp($Type);
	$for var $i = 0; $i < $Type::values.len; $i++:
		desc.constants[$i].name = names[$i].zstr_tcopy();
		desc.constants[$i].value = (long)$Type::values[$i].ordinal;
	$endfor
	return internal::ecs_enum_init(self.raw, &desc);
}

// Register reflection for a C3 `constdef` set with explicit names and values.
macro internal::EcsEntity World.constdef_meta(&self, $Type, String[] names, long[] values)
{
	internal::EcsEnumDesc desc = {};
	desc.entity = self.comp($Type);
	$for var $i = 0; $i < $Type::values.len; $i++:
		desc.constants[$i].name = names[$i].zstr_tcopy();
		desc.constants[$i].value = values[$i];
	$endfor
	return internal::ecs_enum_init(self.raw, &desc);
}

// Register reflection data for a C3 enum type (sequential values).
macro internal::EcsEntity World.enum_meta(&self, $Type)
{
	internal::EcsEnumDesc desc = {};
	desc.entity = self.comp($Type);
	$foreach $i, $val : $Type::values:
		desc.constants[$i].name = $val.description.zstr_tcopy();
		desc.constants[$i].value = (long)$val.ordinal;
	$endforeach
	return internal::ecs_enum_init(self.raw, &desc);
}

// Register reflection data for a C3 enum used as a bitmask. Member ordinal `n`
// is mapped to flag `1 << n` (C3 enums have no explicit values).
macro internal::EcsEntity World.bitmask_meta(&self, $Type)
{
	internal::EcsBitmaskDesc desc = {};
	desc.entity = self.comp($Type);
	$foreach $i, $val : $Type::values:
		desc.constants[$i].name = $val.description.zstr_tcopy();
		desc.constants[$i].value = (ulong)1 << $val.ordinal;
	$endforeach
	return internal::ecs_bitmask_init(self.raw, &desc);
}

// ---------------------------------------------------------------------------
// Meta cursor, opaque types & units
// ---------------------------------------------------------------------------

// Walk/read/write a value of a reflected type without knowing it at compile time.
struct MetaCursor
{
	internal::EcsMetaCursor raw;
}

macro MetaCursor World.meta_cursor(&self, $Type, void* ptr)
{
	return { internal::ecs_meta_cursor(self.raw, self.comp($Type), ptr) };
}

fn int MetaCursor.push(&self) => internal::ecs_meta_push(&self.raw);
fn int MetaCursor.pop(&self) => internal::ecs_meta_pop(&self.raw);
fn int MetaCursor.next(&self) => internal::ecs_meta_next(&self.raw);
fn int MetaCursor.elem(&self, int i) => internal::ecs_meta_elem(&self.raw, i);
fn int MetaCursor.member(&self, ZString name) => internal::ecs_meta_member(&self.raw, name);
fn bool MetaCursor.is_collection(&self) => internal::ecs_meta_is_collection(&self.raw);
fn void* MetaCursor.ptr(&self) => internal::ecs_meta_get_ptr(&self.raw);
fn internal::EcsEntity MetaCursor.type(&self) => internal::ecs_meta_get_type(&self.raw);
fn internal::EcsEntity MetaCursor.unit(&self) => internal::ecs_meta_get_unit(&self.raw);
fn ZString MetaCursor.member_name(&self) => internal::ecs_meta_get_member(&self.raw);
fn bool MetaCursor.get_bool(&self) => internal::ecs_meta_get_bool(&self.raw);
fn char MetaCursor.get_char(&self) => internal::ecs_meta_get_char(&self.raw);
fn long MetaCursor.get_int(&self) => internal::ecs_meta_get_int(&self.raw);
fn ulong MetaCursor.get_uint(&self) => internal::ecs_meta_get_uint(&self.raw);
fn double MetaCursor.get_float(&self) => internal::ecs_meta_get_float(&self.raw);
fn ZString MetaCursor.get_string(&self) => internal::ecs_meta_get_string(&self.raw);
fn internal::EcsEntity MetaCursor.get_entity(&self) => internal::ecs_meta_get_entity(&self.raw);
fn internal::EcsId MetaCursor.get_id(&self) => internal::ecs_meta_get_id(&self.raw);
fn int MetaCursor.set_bool(&self, bool v) => internal::ecs_meta_set_bool(&self.raw, v);
fn int MetaCursor.set_char(&self, char v) => internal::ecs_meta_set_char(&self.raw, v);
fn int MetaCursor.set_int(&self, long v) => internal::ecs_meta_set_int(&self.raw, v);
fn int MetaCursor.set_uint(&self, ulong v) => internal::ecs_meta_set_uint(&self.raw, v);
fn int MetaCursor.set_float(&self, double v) => internal::ecs_meta_set_float(&self.raw, v);
fn int MetaCursor.set_string(&self, ZString v) => internal::ecs_meta_set_string(&self.raw, v);
fn int MetaCursor.set_entity(&self, internal::EcsEntity v) => internal::ecs_meta_set_entity(&self.raw, v);
fn int MetaCursor.set_id(&self, internal::EcsId v) => internal::ecs_meta_set_id(&self.raw, v);
fn int MetaCursor.set_null(&self) => internal::ecs_meta_set_null(&self.raw);

// --- opaque types ----------------------------------------------------------

struct OpaqueOptions
{
	internal::EcsMetaSerialize serialize;
	internal::EcsMetaSerializeMember serialize_member;
	internal::EcsMetaSerializeElement serialize_element;
	internal::EcsMetaAssignBool assign_bool;
	internal::EcsMetaAssignChar assign_char;
	internal::EcsMetaAssignInt assign_int;
	internal::EcsMetaAssignUint assign_uint;
	internal::EcsMetaAssignFloat assign_float;
	internal::EcsMetaAssignString assign_string;
	internal::EcsMetaAssignEntity assign_entity;
	internal::EcsMetaAssignId assign_id;
	internal::EcsMetaAssignNull assign_null;
	internal::EcsMetaClear clear;
	internal::EcsMetaEnsureElement ensure_element;
	internal::EcsMetaEnsureMember ensure_member;
	internal::EcsMetaCount count;
	internal::EcsMetaResize resize;
}

// Register an opaque type: reflection metadata that maps a component to a
// serializable type (e.g. a struct of primitive members).
macro internal::EcsEntity World.opaque(&self, $Type, internal::EcsEntity as_type, OpaqueOptions opts)
{
	internal::EcsOpaqueDesc desc = {};
	desc.entity = self.comp($Type);
	desc.type.as_type = as_type;
	desc.type.serialize = opts.serialize;
	desc.type.serialize_member = opts.serialize_member;
	desc.type.serialize_element = opts.serialize_element;
	desc.type.assign_bool = opts.assign_bool;
	desc.type.assign_char = opts.assign_char;
	desc.type.assign_int = opts.assign_int;
	desc.type.assign_uint = opts.assign_uint;
	desc.type.assign_float = opts.assign_float;
	desc.type.assign_string = opts.assign_string;
	desc.type.assign_entity = opts.assign_entity;
	desc.type.assign_id = opts.assign_id;
	desc.type.assign_null = opts.assign_null;
	desc.type.clear = opts.clear;
	desc.type.ensure_element = opts.ensure_element;
	desc.type.ensure_member = opts.ensure_member;
	desc.type.count = opts.count;
	desc.type.resize = opts.resize;
	return internal::ecs_opaque_init(self.raw, &desc);
}

fn internal::EcsTypeSerializer* World.type_serializer(&self, internal::EcsEntity type)
{
	return (internal::EcsTypeSerializer*)internal::ecs_get_id(self.raw, type,
		internal::ECS_TYPE_SERIALIZER);
}

// --- units -----------------------------------------------------------------

fn Entity World.unit_prefix(&self, ZString symbol, int factor, int power)
{
	internal::EcsUnitPrefixDesc desc = {
		.symbol = symbol,
		.translation = { .factor = factor, .power = power },
	};
	return { internal::ecs_unit_prefix_init(self.raw, &desc) };
}

// ---------------------------------------------------------------------------
// Docs, script, metrics, alerts, app, units, REST
// ---------------------------------------------------------------------------

extern const internal::EcsEntity ECS_GAUGE @cname("EcsGauge");
extern const internal::EcsEntity ECS_COUNTER @cname("EcsCounter");
extern const internal::EcsEntity ECS_COUNTER_INCREMENT @cname("EcsCounterIncrement");
extern const internal::EcsEntity ECS_COUNTER_ID @cname("EcsCounterId");
extern const internal::EcsEntity ECS_ALERT_INFO @cname("EcsAlertInfo");
extern const internal::EcsEntity ECS_ALERT_WARNING @cname("EcsAlertWarning");
extern const internal::EcsEntity ECS_ALERT_ERROR @cname("EcsAlertError");
extern const internal::EcsEntity ECS_ALERT_CRITICAL @cname("EcsAlertCritical");

// --- docs ------------------------------------------------------------------

fn void World.set_brief(&self, Entity e, ZString text)
{
	internal::ecs_doc_set_brief(self.raw, e.id, text);
}

fn ZString World.brief(&self, Entity e)
{
	return internal::ecs_doc_get_brief(self.raw, e.id);
}

fn void World.set_detail(&self, Entity e, ZString text)
{
	internal::ecs_doc_set_detail(self.raw, e.id, text);
}

fn void World.set_link(&self, Entity e, ZString link)
{
	internal::ecs_doc_set_link(self.raw, e.id, link);
}

fn void World.set_color(&self, Entity e, ZString color)
{
	internal::ecs_doc_set_color(self.raw, e.id, color);
}

// --- scripting -------------------------------------------------------------

// Run a Flecs script. Returns true on success.
fn bool World.script(&self, String code)
{
	return internal::ecs_script_run(self.raw, null, code.zstr_tcopy(), null) == 0;
}

// Run a Flecs script file. Returns true on success.
fn bool World.script_file(&self, ZString path)
{
	return internal::ecs_script_run_file(self.raw, path) == 0;
}

// Create a managed script entity from code (updated through `World.script_update`).
fn Entity World.script_init(&self, ZString name, String code)
{
	internal::EcsScriptDesc desc = { .code = code.zstr_tcopy() };
	internal::EcsEntity e = internal::ecs_script_init(self.raw, &desc);
	if (name) internal::ecs_set_name(self.raw, e, name);
	return { e };
}

// Update a managed script and re-sync its entities. Returns true on success.
fn bool World.script_update(&self, Entity script, Entity instance, String code)
{
	return internal::ecs_script_update(self.raw, script.id, instance.id, code.zstr_tcopy()) == 0;
}

// --- expressions & script functions ----------------------------------------

// A typed value (type entity + pointer to storage).
struct Value
{
	internal::EcsValue raw;
}

fn void Value.init(&self, internal::EcsEntity type, void* ptr)
{
	self.raw = { .type = type, .ptr = ptr };
}

fn void Value.free(&self, World* w)
{
	internal::ecs_value_free(w.raw, self.raw.type, self.raw.ptr);
}

// Evaluate an expression, storing the result in `out`. Returns true on success.
fn bool World.expr_run(&self, String expr, Value* out)
{
	return internal::ecs_expr_run(self.raw, expr.zstr_tcopy(), &out.raw, null) != null;
}

// Parse an expression for repeated evaluation. Returns null on failure.
fn internal::EcsScript* World.expr_parse(&self, String expr)
{
	return internal::ecs_expr_parse(self.raw, expr.zstr_tcopy(), null);
}

fn bool World.expr_eval(&self, internal::EcsScript* script, Value* out)
{
	return internal::ecs_expr_eval(script, &out.raw, null) == 0;
}

// Variable scope for scripts/expressions.
struct ScriptVars
{
	internal::EcsScriptVars* raw;
}

fn ScriptVars World.script_vars(&self)
{
	return { internal::ecs_script_vars_init(self.raw) };
}

fn void ScriptVars.fini(&self)
{
	internal::ecs_script_vars_fini(self.raw);
}

fn internal::EcsScriptVar* ScriptVars.declare(&self, ZString name)
{
	return internal::ecs_script_vars_declare(self.raw, name);
}

fn internal::EcsScriptVar* ScriptVars.define(&self, ZString name, internal::EcsEntity type)
{
	return internal::ecs_script_vars_define_id(self.raw, name, type);
}

fn internal::EcsScriptVar* ScriptVars.lookup(&self, ZString name)
{
	return internal::ecs_script_vars_lookup(self.raw, name);
}

// Register a script function callable as `name(args...)`.
macro internal::EcsEntity World.function(&self, ZString name, internal::EcsEntity return_type,
	internal::EcsScriptParameter[] params, internal::EcsFunctionCallback callback)
{
	internal::EcsFunctionDesc desc = { .name = name, .return_type = return_type, .callback = callback };
	for (int i = 0; i < params.len; i++) desc.params[i] = params[i];
	return internal::ecs_function_init(self.raw, &desc);
}

// Register a script method callable on instances of `parent`.
macro internal::EcsEntity World.method(&self, internal::EcsEntity parent, ZString name,
	internal::EcsEntity return_type, internal::EcsScriptParameter[] params,
	internal::EcsFunctionCallback callback)
{
	internal::EcsFunctionDesc desc = {
		.name = name, .parent = parent, .return_type = return_type, .callback = callback,
	};
	for (int i = 0; i < params.len; i++) desc.params[i] = params[i];
	return internal::ecs_method_init(self.raw, &desc);
}

// --- modules ---------------------------------------------------------------

// Create a module entity (component names registered while scoped to it become
// namespaced under the module).
fn Entity World.module_init(&self, ZString name)
{
	internal::EcsComponentDesc desc = {};
	return { internal::ecs_module_init(self.raw, name, &desc) };
}

fn Entity World.import_module(&self, ZString name, internal::EcsModuleAction action)
{
	return { internal::ecs_import(self.raw, action, name) };
}

fn Entity World.set_scope(&self, Entity scope)
{
	return { internal::ecs_set_scope(self.raw, scope.id) };
}

fn Entity World.get_scope(&self)
{
	return { internal::ecs_get_scope(self.raw) };
}

// --- small helpers ---------------------------------------------------------

fn Entity World.target(&self, Entity e, internal::EcsEntity rel, int index = 0)
{
	return { internal::ecs_get_target(self.raw, e.id, rel, index) };
}

fn void World.defer_suspend(&self)
{
	internal::ecs_defer_suspend(self.raw);
}

fn void World.defer_resume(&self)
{
	internal::ecs_defer_resume(self.raw);
}

macro void World.singleton_set(&self, $Type, #value) @safemacro
{
	$Type v = #value;
	internal::ecs_set_id(self.raw, self.comp($Type), self.comp($Type), (internal::EcsSize)$Type::size, &v);
}

macro World.singleton_get(&self, $Type)
{
	return ($Type*)internal::ecs_get_id(self.raw, self.comp($Type), self.comp($Type));
}

// Create a custom phase that depends on `depends_on` (default `ECS_ON_UPDATE`).
fn Entity World.phase(&self, ZString name, internal::EcsEntity depends_on = 0)
{
	Entity e = self.entity(name);
	internal::ecs_add_id(self.raw, e.id, ECS_PHASE);
	internal::ecs_add_id(self.raw, e.id,
		internal::ecs_make_pair(ECS_DEPENDS_ON, depends_on ? depends_on : ECS_ON_UPDATE));
	return e;
}

// Create a child entity of a prefab (also tagged Prefab).
fn Entity World.prefab_child(&self, Entity parent, ZString name)
{
	internal::EcsEntityDesc desc = { .parent = parent.id, .name = name };
	Entity e = { internal::ecs_entity_init(self.raw, &desc) };
	internal::ecs_add_id(self.raw, e.id, ECS_PREFAB);
	return e;
}

fn void World.sleep(&self, double seconds)
{
	internal::EcsOsApi api = internal::ecs_os_get_api();
	if (api.sleep_)
	{
		int sec = (int)seconds;
		int nsec = (int)((seconds - (double)sec) * 1_000_000_000.0);
		api.sleep_(sec, nsec);
	}
}

fn int World.search(&self, internal::EcsTable* table, internal::EcsId id)
{
	return internal::ecs_search(self.raw, table, id, null);
}

// --- metrics ---------------------------------------------------------------

// Import the metrics addon (not imported by `ecs_init`). Required before
// creating metrics.
fn void World.import_metrics(&self)
{
	internal::ecs_import(self.raw, &internal::flecs_metrics_import, "flecs.metrics");
}

// Import the stats addon (not imported by `ecs_init`). Required by the explorer.
fn void World.import_stats(&self)
{
	internal::ecs_import(self.raw, &internal::flecs_stats_import, "flecs.stats");
}

fn Entity World.metric(&self, internal::EcsEntity kind, internal::EcsId id, ZString brief = null)
{
	internal::EcsMetricDesc desc = { .id = id, .kind = kind, .brief = brief };
	return { internal::ecs_metric_init(self.raw, &desc) };
}

// --- alerts ----------------------------------------------------------------

// Import the alerts addon (not imported by `ecs_init`).
fn void World.import_alerts(&self)
{
	internal::ecs_import(self.raw, &internal::flecs_alerts_import, "flecs.alerts");
}

fn Entity World.alert(&self, ZString name, internal::EcsEntity severity, ZString message, ZString expr)
{
	internal::EcsAlertDesc desc = {};
	desc.severity = severity;
	desc.message = message;
	desc.query.expr = expr;
	internal::EcsEntity e = internal::ecs_alert_init(self.raw, &desc);
	if (name) internal::ecs_set_name(self.raw, e, name);
	return { e };
}

fn int World.alert_count(&self, Entity e, Entity alert)
{
	return internal::ecs_get_alert_count(self.raw, e.id, alert.id);
}

// --- app -------------------------------------------------------------------

// Run the application main loop (frames = 0 for infinite).
fn int World.app_run(&self, int frames = 0, double target_fps = 60.0)
{
	internal::EcsAppDesc desc = { .frames = frames, .target_fps = (float)target_fps };
	return internal::ecs_app_run(self.raw, &desc);
}

// --- units -----------------------------------------------------------------

// Import the units addon (not imported by `ecs_init`).
fn void World.import_units(&self)
{
	internal::ecs_import(self.raw, &internal::flecs_units_import, "flecs.units");
}

fn Entity World.unit(&self, ZString symbol, Entity quantity = { 0 }, Entity base = { 0 },
	Entity over = { 0 }, Entity prefix = { 0 })
{
	internal::EcsUnitDesc desc = {
		.symbol = symbol,
		.quantity = quantity.id,
		.base = base.id,
		.over = over.id,
		.prefix = prefix.id,
	};
	return { internal::ecs_unit_init(self.raw, &desc) };
}

// --- REST ------------------------------------------------------------------

struct RestServer
{
	internal::EcsHttpServer* raw;
}

// Start a REST server (exposes the world over HTTP, used by the explorer).
fn RestServer World.rest_server(&self, ushort port = 0)
{
	internal::EcsHttpServerDesc desc = { .port = port };
	return { internal::ecs_rest_server_init(self.raw, &desc) };
}

fn void RestServer.fini(&self)
{
	internal::ecs_rest_server_fini(self.raw);
}

// ---------------------------------------------------------------------------
// Statistics
//
// Stats structs are large (e.g. WorldStats is ~73 KB); store them on the heap
// or in a long-lived buffer.
// ---------------------------------------------------------------------------

alias WorldStats = internal::EcsWorldStats;
alias QueryStats = internal::EcsQueryStats;
alias SystemStats = internal::EcsSystemStats;
alias PipelineStats = internal::EcsPipelineStats;

fn void World.world_stats(&self, WorldStats* out) => internal::ecs_world_stats_get(self.raw, out);

fn void World.query_stats(&self, Query* query, QueryStats* out)
{
	internal::ecs_query_stats_get(self.raw, query.raw, out);
}

fn bool World.system_stats(&self, Entity system, SystemStats* out)
{
	return internal::ecs_system_stats_get(self.raw, system.id, out);
}

fn bool World.pipeline_stats(&self, Entity pipeline, PipelineStats* out)
{
	return internal::ecs_pipeline_stats_get(self.raw, pipeline.id, out);
}

fn void World.pipeline_stats_fini(&self, PipelineStats* stats)
{
	internal::ecs_pipeline_stats_fini(stats);
}

// ---------------------------------------------------------------------------
// OS API
// ---------------------------------------------------------------------------

// Access the OS API for full customization.
alias OsApi = internal::EcsOsApi;

fn OsApi os_get_api() => internal::ecs_os_get_api();

fn void os_set_api(OsApi* api) => internal::ecs_os_set_api(api);

fn void os_set_api_defaults() => internal::ecs_os_set_api_defaults();

// Convenience: override just the abort handler.
fn void set_os_abort(internal::EcsOsApiAbort callback)
{
	internal::ecs_os_set_api_defaults();
	internal::EcsOsApi api = internal::ecs_os_get_api();
	api.abort_ = callback;
	internal::ecs_os_set_api(&api);
}

// Convenience: override just the log handler.
fn void set_os_log(internal::EcsOsApiLog callback)
{
	internal::ecs_os_set_api_defaults();
	internal::EcsOsApi api = internal::ecs_os_get_api();
	api.log_ = callback;
	internal::ecs_os_set_api(&api);
}

// ---------------------------------------------------------------------------
// Logging
// ---------------------------------------------------------------------------

// Set the verbosity level of the Flecs logger. Returns the previous level.
fn int set_log_level(int level)
{
	return internal::ecs_log_set_level(level);
}

fn int log_level()
{
	return internal::ecs_log_get_level();
}

fn void enable_log_colors(bool enabled = true)
{
	internal::ecs_log_enable_colors(enabled);
}

fn void enable_log_timestamp(bool enabled = true)
{
	internal::ecs_log_enable_timestamp(enabled);
}
