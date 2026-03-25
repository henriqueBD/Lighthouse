extends Node

const CHARACTER_GROUP_NAME: String = "Characters"

const DIALOGUE_SPEED_PER_CHAR: float = 0.05

enum global_variables_bool{
	NULL,
	SAW_MAP_ON_LIGHTHOUSE_LIVING_ROOM
}

signal interact_pressed
signal room_faded_in

var _is_playing_cutscene: bool

#Important nodes
var main_node: ManagerMainNode
var save_data: SaveData = SaveData.new()
var player: Player
var player_parent: Character

#Global varibles
var _entities: Dictionary[String, Tracker]
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

func set_player(player_to_add: Player) -> void:
	assert(not player, "two players on scene")
	player = player_to_add
	player_parent = player.get_parent()
	assert(player_parent)

func get_string_var(key: String) -> String:
	return _global_variables_string_map.get(key, "")

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
		if _entities.has(name_space):
			_entities[name_space].call_method(method_name, arguments)
		else:
			assert(false, "invalid namespace: " + name_space)

func register_unique_entity(unique_name: String, node: Node) -> void:
	assert(not _entities.has(unique_name), "Name " + unique_name + "is not unique")
	_entities[unique_name] = node

func register_spawn_point(point: Transition) -> void:
	assert(not _spawn_points_on_current_room.has(point.name), 
	"Two transitions with the same name " + point.name)
	
	_spawn_points_on_current_room[point.name] = point

func get_spawn_point(point_name: String) -> Transition:
	assert(_spawn_points_on_current_room.has(point_name), "No spawn with name: " + point_name)
	return _spawn_points_on_current_room[point_name]

func unregister_unique_entity(unique_name: String) -> void:
	assert(_entities.has(unique_name), "No active entity with name: " + unique_name)
	_entities.erase(unique_name)

func get_unique_entity(unique_name: String) -> Tracker:
	assert(_entities.has(unique_name), "No active entity with name: " + unique_name)
	return _entities.get(unique_name)

func get_unique_entity_parent(unique_name: String) -> Node2D:
	var catch: Tracker = _entities.get(unique_name)
	if catch:
		return catch.get_parent()
	assert(false, "No active entity with name: " + unique_name)
	return null

func get_marker(unique_name: String) -> Marker:
	var marker: Marker = main_node.curr_map.get_node_or_null(unique_name)
	assert(marker, "No marker with name " + unique_name)
	return marker

func get_character(unique_name: String) -> Character:
	return main_node.curr_map.get_character(unique_name)

func is_player_locked() -> bool:
	return _is_playing_cutscene

func set_global_var(var_name: String, value: Variant) -> void:
	assert(main_node.curr_map is Place)
	if main_node.curr_map is Place:
		main_node.curr_map.save_var(var_name, value)

func get_local_var(path: String) -> Variant:
	return main_node.curr_map.get_var(path)

func local_var_exists(path: String) -> bool:
	return main_node.curr_map.var_exists(path)

func set_local_var(path: String, value: Variant) -> void:
	main_node.curr_map.save_var(path, value)

func toggle_is_playing_cutscene(val: bool) -> void:
	_is_playing_cutscene = val

#endregion

func set_process_func(fn: Callable) -> void:
	set_process(not fn.is_null())
	_process_func = fn

func _process(delta: float) -> void:
	_process_func.call(delta)

func toggle_listen_input(value: bool) -> void:
	set_process_unhandled_input(value)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Interact"):
		interact_pressed.emit()

func change_scene(new_scene_path: String, spawn_name: String) -> void:
	_spawn_points_on_current_room.clear()
	main_node.change_scene(new_scene_path, spawn_name, player_parent)

func teleport_entity_to_marker(entity_name: String, marker_name: String) -> void:
	var entity: Node2D = get_unique_entity_parent(entity_name)
	var marker: Marker = get_marker(marker_name)
	if entity and marker:
		entity.global_position = marker.global_position

func fade_in_finished() -> void:
	room_faded_in.emit()

func count_down(wait_time_sec: float) -> Signal:
	if wait_time_sec > 0.0:
		return get_tree().create_timer(wait_time_sec).timeout
	assert(false, "Invalid time: " + str(wait_time_sec))
	return get_tree().create_timer(0.1).timeout
