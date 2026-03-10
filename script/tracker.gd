class_name Tracker
extends Node

@export var unique_name: String
@export var sources: Array[Node]
@export var method_name: PackedStringArray

var _actions: Dictionary[String, Callable]

func _enter_tree() -> void:
	assert(unique_name, "null name at " + str(get_path()))
	assert(not unique_name.is_empty(), "empty name at " + str(get_path()))
	assert(sources.size() == method_name.size(), "no")
	
	for i: int in range(sources.size()):
		assert(sources[i], "no source")
		if sources[i].has_method(method_name[i]):
			_actions[method_name[i]] = Callable(sources[i], method_name[i])
			continue
		assert(false, "Invalid method: " + method_name[i] + "at" + str(get_path()))
	
	GameManager.register_unique_entity(unique_name, self)

func _exit_tree() -> void:
	GameManager.unregister_unique_entity(unique_name)

func call_method(to_call: String, arguments: PackedStringArray) -> void:
	#assert(arguments.is_empty(), "not implemented yet")
	if _actions.has(to_call):
		var tmp: Callable = _actions[to_call]
		if tmp.is_valid():
			if arguments.is_empty(): tmp.call()
			else: tmp.call(arguments)
			return
		assert(false, "invalid method: " + to_call)
	assert(false, "no method on namespace " + unique_name + "with name: " + to_call)
