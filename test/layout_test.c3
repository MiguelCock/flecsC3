module flecs_layout_test @test;

import flecs::internal;

macro usz @offset($Type, #field)
{
	$Type* t = (($Type*)mem::malloc($Type::size));
	defer mem::free(t);
	return (usz)&t.$eval($stringify(#field)) - (usz)t;
}

// Guards against ABI drift between the vendored amalgamated C build and the
// hand-written C3 structs. Values below are the C sizes for Flecs 4.1.6 built
// with FLECS_DEBUG (the default in flecs.c3l/manifest.json).
fn void test_struct_sizes()
{
	assert(EcsType::size == 16);
	assert(EcsTermRef::size == 16);
	assert(EcsTerm::size == 72);
	assert(EcsValue::size == 16);
	assert(EcsEntityDesc::size == 88);
	assert(EcsBulkDesc::size == 296);
	assert(EcsComponentDesc::size == 208);
	assert(EcsQueryDesc::size == 2440);
	assert(EcsObserverDesc::size == 2608);
	assert(EcsEventDesc::size == 80);
	assert(EcsSystemDesc::size == 2552);
	assert(EcsPipelineDesc::size == 2448);
	assert(EcsTypeHooks::size == 168);
	assert(EcsTypeInfo::size == 192);
	assert(EcsIter::size == 368);
	assert(EcsIterPrivate::size == 112);
	assert(EcsBuildInfo::size == 48);
	assert(EcsWorldInfo::size == 288);
	assert(EcsEntityRange::size == 32);
	assert(EcsRef::size == 40);
	assert(EcsVec::size == 16);
	assert(EcsOsApi::size == 352);
	assert(EcsTime::size == 8);
	assert(EcsGauge::size == 720);
	assert(EcsCounter::size == 1200);
	assert(EcsMetric::size == 1200);
	assert(EcsWorldStats::size == 73224);
	assert(EcsQueryStats::size == 3624);
	assert(EcsSystemStats::size == 4848);
	assert(EcsPipelineStats::size == 56);
}

fn void test_struct_offsets()
{
	assert(@offset(EcsEntityDesc, add_expr) == 80);
	assert(@offset(EcsComponentDesc, type) == 16);
	assert(@offset(EcsQueryDesc, terms) == 8);
	assert(@offset(EcsQueryDesc, entity) == 2432);
	assert(@offset(EcsObserverDesc, query) == 16);
	assert(@offset(EcsObserverDesc, events) == 2456);
	assert(@offset(EcsSystemDesc, query) == 16);
	assert(@offset(EcsIter, priv_) == 224);
	assert(@offset(EcsIter, next) == 336);
	assert(@offset(EcsTypeInfo, hooks) == 8);
	assert(@offset(EcsWorldInfo, cmd) == 184);
	assert(@offset(EcsWorldInfo, name_prefix) == 280);
	assert(@offset(EcsTypeHooks, on_add) == 88);
	assert(@offset(EcsTypeHooks, flags) == 80);
	assert(@offset(EcsOsApi, malloc_) == 16);
	assert(@offset(EcsOsApi, free_) == 40);
	assert(@offset(EcsOsApi, log_) == 224);
	assert(@offset(EcsOsApi, abort_) == 232);
	assert(@offset(EcsOsApi, log_level_) == 312);
	assert(@offset(EcsOsApi, log_out_) == 344);
	assert(@offset(EcsWorldStats, entities) == 8);
	assert(@offset(EcsWorldStats, components) == 2408);
	assert(@offset(EcsWorldStats, http) == 62408);
	assert(@offset(EcsWorldStats, last_) == 73208);
	assert(@offset(EcsWorldStats, t) == 73216);
	assert(@offset(EcsSystemStats, query) == 1224);
}

fn void test_meta_layouts() @test
{
	assert(EcsMetaOp::size == 56);
	assert(EcsMetaScope::size == 64);
	assert(EcsMetaCursor::size == 2080);
	assert(EcsTypeSerializer::size == 24);
	assert(EcsOpaque::size == 144);
	assert(EcsSerializer::size == 32);
	assert(EcsUnit::size == 40);
	assert(EcsUnitPrefix::size == 16);
	assert(EcsFunctionDesc::size == 440);
	assert(EcsScriptVar::size == 40);
	assert(EcsScriptParameter::size == 16);
	assert(EcsExprEvalDesc::size == 80);
	assert(@offset(EcsMetaCursor, scope) == 8);
	assert(@offset(EcsMetaCursor, depth) == 2056);
	assert(@offset(EcsMetaCursor, lookup_action) == 2064);
	assert(@offset(EcsOpaque, assign_bool) == 32);
	assert(@offset(EcsOpaque, ensure_element) == 112);
	assert(@offset(EcsOpaque, count) == 128);
	assert(@offset(EcsFunctionDesc, params) == 16);
	assert(@offset(EcsFunctionDesc, callback) == 280);
	assert(@offset(EcsFunctionDesc, vector_callbacks) == 288);
	assert(@offset(EcsExprEvalDesc, type) == 24);
	assert(@offset(EcsExprEvalDesc, disable_folding) == 48);
}
