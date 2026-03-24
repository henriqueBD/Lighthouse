@icon("res://z_editor_only/place_icon.svg")
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
var _actions_dict: Dictionary[String, Array]
var _entities: Node2D

func get_character(character_name: String) -> Character:
	if not _entities:
		assert(false)
		return null
	var res: Node = _entities.get_node_or_null(character_name)
	assert(res, "No character with name " + character_name)
	if res and res is Character:
		return res
	assert(res, "Node " + character_name + " is not of type character")
	return null

func _enter_tree() -> void:
	assert(location_path != places.UNASSIGNED)
	_location = _places_keys[location_path]
	GameManager.save_data.create_folder(_location)

func _ready() -> void:
	_entities = get_node_or_null("%Entities")
	
	if not actions: 
		return
	_actions_dict = {}
	
	for single_action: ConditionRule in actions:
		if _actions_dict.has(single_action.target_var):
			_actions_dict[single_action.target_var].append(single_action)
		else:
			var new_array: Array[ConditionRule] = [single_action]
			_actions_dict[single_action.target_var] = new_array
		_call_action_if_condition(single_action)
	
	actions.clear()

func save_var(var_name: String, value: Variant) -> void:
	GameManager.save_data.store_var("%s/%s" % [_location, var_name], value)
	if _actions_dict.has(var_name):
		for action: ConditionRule in _actions_dict[var_name] as Array[ConditionRule]:
			_call_action_if_condition(action)

func get_var(local_path: String) -> Variant:
	return GameManager.save_data.get_var_or_null("%s/%s" % [_location, local_path])

func var_exists(local_path: String) -> bool:
	return GameManager.save_data.var_exists("%s/%s" % [_location, local_path])

func _call_action_if_condition(action: ConditionRule) -> void:
	assert(action)
	assert(_method_exists(action))
	
	#get var
	var target: Variant = get_var(action.target_var)
	if not target: 
		if action.operation == ConditionRule.Operation.IS_NULL:
			_call_action_unconditional(action)
		return
	
	#evaluate
	match action.operation:
		ConditionRule.Operation.EXISTS:
			_call_action_unconditional(action)
		ConditionRule.Operation.EQUAL:
			if target == action.comparison_value:
				_call_action_unconditional(action)
		ConditionRule.Operation.DIFFERENT:
			if target != action.comparison_value:
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
		assert(target_method.get_argument_count() == action.method_arguments.size())
		if target_method.get_argument_count() == action.method_arguments.size():
			target_method.callv(action.method_arguments)
	else:
		target_method.call()

func _method_exists(action: ConditionRule) -> bool:
	var target_method: Callable
	var target_node: Node = get_node(action.source)
	if target_node.has_method(action.method_name):
		target_method = Callable(target_node, action.method_name)
	return target_method and target_method.is_valid()
