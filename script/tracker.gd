@icon("res://z_editor_only/tracker_icon.svg")
class_name Tracker
extends Node

@export var sources: Array[Node]
@export var method_name: PackedStringArray

var _actions: Dictionary[String, Callable]
var _name: String

func _enter_tree() -> void:
	_name = get_parent().name
	assert(sources.size() == method_name.size(), "no")
	
	for i: int in range(sources.size()):
		assert(sources[i], "no source")
		if sources[i].has_method(method_name[i]):
			_actions[method_name[i]] = Callable(sources[i], method_name[i])
			continue
		assert(false, "Invalid method: " + method_name[i] + "at" + str(get_path()))
	
	GameManager.register_unique_entity(_name, self)

func _exit_tree() -> void:
	GameManager.unregister_unique_entity(_name)

func call_method(to_call: String, arguments: PackedStringArray) -> void:
	if _actions.has(to_call):
		var tmp: Callable = _actions[to_call]
		if tmp.is_valid():
			if arguments.is_empty(): tmp.call()
			else: tmp.call(arguments)
			return
		assert(false, "invalid method: " + to_call)
	assert(false, "no method on namespace " + _name + "with name: " + to_call)
