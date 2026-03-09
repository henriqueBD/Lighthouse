class_name DataConditional
extends Node

#Example usage: varaiable_name|==|true|queue_free()

@export var conditions: PackedStringArray
@export var sources: Array[Node]
@export var custom_call_names: PackedStringArray
@export var method_name: PackedStringArray

var _actions: Dictionary[String, Callable]

func _enter_tree() -> void:
	assert(sources.size() == method_name.size(), "no")
	
	if not custom_call_names:
		custom_call_names = method_name
	else:
		assert(custom_call_names.size() == sources.size())
	
	for i: int in range(sources.size()):
		assert(sources[i], "no source")
		assert(sources[i].has_method(method_name[i]), "Invalid method: " + method_name[i])
		if sources[i].has_method(method_name[i]):
			_actions[custom_call_names[i]] = Callable(sources[i], method_name[i])

func _ready() -> void:
	for condition: String in conditions:
		var parts: PackedStringArray = condition.split("|")

func call_method(to_call: String, arguments: PackedStringArray) -> void:
	assert(_actions.has(to_call), "no methodwith name: " + to_call)
	if _actions.has(to_call):
		var tmp: Callable = _actions[to_call]
		assert(tmp.is_valid(), "invalid method: " + to_call)
		if tmp.is_valid():
			if arguments.is_empty(): tmp.call()
			else: tmp.call(arguments)
