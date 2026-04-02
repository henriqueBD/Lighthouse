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
			if action.apply_immediatly:
				_call_action_if_condition(action)

func get_var(local_path: String) -> Variant:
	return GameManager.save_data.get_var_or_null("%s/%s" % [_location, local_path])

func var_exists(local_path: String) -> bool:
	return GameManager.save_data.var_exists("%s/%s" % [_location, local_path])

func _call_action_if_condition(action: ConditionRule) -> void:
	assert(action)
	if var_exists(action.target_var):
		_call_action_unconditional(action)

func _call_action_unconditional(action: ConditionRule) -> void:
	action.action.execute(self)
