class_name ConditionRule
extends Resource

enum Operation {
	UNASSIGNED,
	EQUAL,
	GREATER,
	LESS,
}

@export var target_var: String
@export var operation: Operation
@export var comparison_value: Variant
@export var source: NodePath
@export var method_name: String
@export var method_arguments: PackedStringArray
