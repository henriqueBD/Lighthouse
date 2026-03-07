extends Node

const DIALOGUE_SPEED_PER_CHAR: float = 0.1

enum global_variables_bool{
	NULL,
	SAW_MAP_ON_LIGHTHOUSE_LIVING_ROOM
}

signal interact_pressed

var is_playing_dialogue: bool

#Important nodes
var main_node: ManagerMainNode
var _player: Player
var _player_parent: Character

#Global varibles
var _unique_entities_map: Dictionary[String, Tracker]
var _global_variables_bool_map: Dictionary[global_variables_bool, bool]
var _global_variables_string_map: Dictionary[String, String]

#Misc
var _spawn_points_on_current_room: Dictionary[String, Transition] = {}
var _process_func: Callable

var _global_methods_map: Dictionary[String, Callable] = {
	"test" : func() -> void: 
		print("Hello, world"),
	"test2" : func() -> void:
		print("Hello again")
}

func _ready() -> void:
	set_process_unhandled_input(false)
	set_process(false)

#region variables

func set_main_node(node_to_add: ManagerMainNode) -> void:
	assert(not main_node, "main node set twice")
	main_node = node_to_add

func set_player(player: Player) -> void:
	assert(not _player, "two players on scene")
	_player = player
	_player_parent = _player.get_parent()
	assert(_player_parent)

func get_string_var(key: String) -> String:
	return _global_variables_string_map.get(key, "")

func bool_is_active(key: global_variables_bool) -> bool:
	return _global_variables_bool_map.has(key)

func bool_set(key: global_variables_bool, value: bool) -> void:
	if value:
		assert(not _global_variables_bool_map.has(key), "Tried to add global bool twice")
		_global_variables_bool_map[key] = true
	else:
		if _global_variables_bool_map.has(key):
			_global_variables_bool_map.erase(key)
		else:
			assert(false, "Tried to erase a null global bool")

func call_global_method(name_space: String, method_name: String, arguments: PackedStringArray) -> void:
	assert(not method_name.is_empty(), "method name is empty")
	if name_space.is_empty():
		if _global_methods_map.has(method_name):
			if arguments.is_empty(): 
				_global_methods_map[method_name].call()
			else: 
				_global_methods_map[method_name].call(arguments)
		else:
			assert(false, "no function with name " + method_name)
	else:
		if _unique_entities_map.has(name_space):
			_unique_entities_map[name_space].call_method(method_name, arguments)
		else:
			assert(false, "invalid namespace: " + name_space)

func register_unique_entity(unique_name: String, node: Node) -> void:
	assert(not _unique_entities_map.has(unique_name), "Name " + unique_name + "is not unique")
	_unique_entities_map[unique_name] = node

func register_spawn_point(point: Transition) -> void:
	assert(not _spawn_points_on_current_room.has(point.transition_name), 
	"Two transitions with the same name " + point.transition_name)
	
	_spawn_points_on_current_room[point.transition_name] = point

func get_spawn_point(point_name: String) -> Transition:
	assert(_spawn_points_on_current_room.has(point_name), "No spawn with name: " + point_name)
	return _spawn_points_on_current_room[point_name]

func unregister_unique_entity(unique_name: String) -> void:
	assert(_unique_entities_map.has(unique_name), "No active entity with name: " + unique_name)
	_unique_entities_map.erase(unique_name)

func get_unique_entity(unique_name: String) -> Tracker:
	assert(_unique_entities_map.has(unique_name), "No active entity with name: " + unique_name)
	return _unique_entities_map[unique_name]

func get_unique_entity_parent(unique_name: String) -> Node2D:
	assert(_unique_entities_map.has(unique_name), "No active entity with name: " + unique_name)
	return _unique_entities_map[unique_name].get_parent()

func is_player_locked() -> bool:
	return is_playing_dialogue

#endregion

func set_process_func(fn: Callable) -> void:
	set_process(not fn.is_null())
	_process_func = fn

func _process(delta: float) -> void:
	_process_func.call(delta)

##Also locks the player
func toggle_listen_input(value: bool) -> void:
	set_process_unhandled_input(value)
	is_playing_dialogue = value

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Interact"):
		interact_pressed.emit()

func change_scene(new_scene: PackedScene, spawn_name: String) -> void:
	_spawn_points_on_current_room.clear()
	main_node.change_scene(new_scene, spawn_name, _player_parent)
