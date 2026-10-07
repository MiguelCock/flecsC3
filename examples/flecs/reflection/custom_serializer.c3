// Port of Flecs example: reflection/custom_serializer
//
// Demonstrates how to serialize a value of a reflected type by walking the
// meta serializer instructions (world.type_serializer). Enum constant maps and
// opaque callbacks are not exposed by the bindings, so this port serializes
// nested structs of primitive members.
// G: enum constant maps / opaque callbacks are not exposed.
module flecs_ex_refl_custom_ser;

import flecs;
import flecs::internal;
import std::io;

struct Point
{
	float x;
	float y;
}

struct Segment
{
	Point start;
	Point stop;
	uint weight;
}

int indent = 0;

fn void print_indent()
{
	for (int i = 0; i < indent; i++) io::printf("  ");
}

fn void serialize_struct(internal::EcsMetaOp* op, char* ptr)
{
	io::printf("{");
	indent++;
	serialize_ops(op + 1, op.op_count - 2, ptr);
	indent--;
	io::printf("\n");
	print_indent();
	io::printf("}");
}

fn void serialize_ops(internal::EcsMetaOp* ops, int op_count, char* base)
{
	for (int i = 0; i < op_count; i++)
	{
		internal::EcsMetaOp* op = &ops[i];
		if (op.name)
		{
			if (i) io::printf(",");
			io::printf("\n");
			print_indent();
			io::printf("%s: ", op.name.str_view());
		}

		char* ptr = base + op.offset;
		switch (op.kind)
		{
			case internal::EcsMetaOpKind.OP_PUSH_STRUCT:
				serialize_struct(op, ptr);
				break;
			case internal::EcsMetaOpKind.OP_F32:
				io::printf("%.2f", (double)*(float*)ptr);
				break;
			case internal::EcsMetaOpKind.OP_F64:
				io::printf("%.2f", *(double*)ptr);
				break;
			case internal::EcsMetaOpKind.OP_I32:
				io::printf("%d", *(int*)ptr);
				break;
			case internal::EcsMetaOpKind.OP_U32:
				io::printf("%d", (int)*(uint*)ptr);
				break;
			case internal::EcsMetaOpKind.OP_BOOL:
				io::printf("%s", *(bool*)ptr ? "true" : "false");
				break;
			case internal::EcsMetaOpKind.OP_ENUM:
				io::printf("%d", *(int*)ptr);
				break;
			default:
				io::printf("<unsupported>");
				break;
		}

		i += op.op_count - 1; // skip over already processed instructions
	}
}

fn void serialize(internal::EcsTypeSerializer* s, char* ptr)
{
	if (!s)
	{
		io::printfn("type does not have reflection data");
		return;
	}
	serialize_ops((internal::EcsMetaOp*)s.ops.array, s.ops.count, ptr);
}

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	w.struct_meta(Segment);

	Segment s = {
		.start = { .x = 10, .y = 20 },
		.stop = { .x = 30, .y = 40 },
		.weight = 5,
	};

	serialize(w.type_serializer(w.comp(Segment)), (char*)&s);
	io::printfn("");
}
