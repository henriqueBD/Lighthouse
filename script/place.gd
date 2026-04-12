@icon("res://z_editor_only/place_icon.svg")
class_name Place
extends Node

enum Places{
	UNASSIGNED,
	LIGHTHOUSE_MAIN_HOUSE
}

static var _places_keys: Array = Places.keys()

@export var location_path: Places
@export var is_outdoor: bool

var _location: String
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

func subscribe_to_var(variable: GameVariable) -> Signal:
	var ID: String = variable.get_ID()
	if not has_signal(ID):
		add_user_signal(ID)
	return Signal(self, ID)

func _enter_tree() -> void:
	assert(location_path != Places.UNASSIGNED)
	_location = _places_keys[location_path]
	_entities = get_node_or_null("%Entities")
	GameManager.save_data.create_folder(_location)

func save_var(variable: GameVariable, _value: Variant) -> void:
	GameManager.save_data.store_var(_location, variable)
	var ID: String = variable.get_ID()
	if has_signal(ID):
		Signal(self, ID).emit()

func get_var(variable: GameVariable) -> Variant:
	return GameManager.save_data.get_var_or_null(_location, variable)

func var_exists(variable: GameVariable) -> bool:
	return GameManager.save_data.var_exists(_location, variable)

func _call_action_if_condition(action: ConditionRule) -> void:
	assert(action)
	if var_exists(action.target_var):
		_call_action_unconditional(action)

func _call_action_unconditional(action: ConditionRule) -> void:
	action.action.execute(self)
