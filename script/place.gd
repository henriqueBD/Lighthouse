class_name Place
extends Node

enum places{
	UNASSIGNED,
	LIGHTHOUSE_MAIN_HOUSE
}

static var _places_keys: Array = places.keys()

@export var location_path: places
@export var actions: Array[ConditionRule]

var _location: String
var _actions_dict: Dictionary[String, ConditionRule]

func _enter_tree() -> void:
	assert(location_path != places.UNASSIGNED)
	_location = _places_keys[location_path]
	GameManager.save_data.create_folder(_location)

func _ready() -> void:
	assert(actions, "Missing action for " + str(get_path()))
	if not actions: return
	_actions_dict = {}
	
	for action: ConditionRule in actions:
		assert(not _actions_dict.has(action.target_var), "Not implemented one var having multiple actions")
		_actions_dict[action.target_var] = action
		_call_action_if_condition(action)
	
	actions.clear()

func save_var(var_name: String, value: Variant) -> void:
	GameManager.save_data.store_var("%s/%s" % [_location, var_name], value)
	if _actions_dict.has(var_name):
		print("updating")
		_call_action_if_condition(_actions_dict[var_name])

func get_var(local_path: String) -> Variant:
	return GameManager.save_data.get_var_or_null("%s/%s" % [_location, local_path])

func _call_action_if_condition(action: ConditionRule) -> void:
	assert(action)
	assert(_method_exists(action))
	#get var
	var target: Variant = get_var(action.target_var)
	if not target: return
	
	#evaluate
	match action.operation:
		ConditionRule.Operation.EQUAL:
			if target == action.comparison_value:
				_call_action_unconditional(action)
		ConditionRule.Operation.LESS:
			if target < action.comparison_value:
				_call_action_unconditional(action)
		ConditionRule.Operation.GREATER:
			if target > action.comparison_value:
				_call_action_unconditional(action)
		_:
			assert(false, "what")

func _call_action_unconditional(action: ConditionRule) -> void:
	var target_method: Callable
	var target_node: Node = get_node(action.source)
	assert(target_node, "No such node " + str(action.source))
	if target_node and target_node.has_method(action.method_name):
		target_method = Callable(target_node, action.method_name)
	assert(target_method and target_method.is_valid())
	if not target_method.is_valid(): return
	if action.method_arguments:
		target_method.call(action.method_arguments)
	else:
		target_method.call()

func _method_exists(action: ConditionRule) -> bool:
	var target_method: Callable
	var target_node: Node = get_node(action.source)
	if target_node.has_method(action.method_name):
		target_method = Callable(target_node, action.method_name)
	return target_method and target_method.is_valid()
