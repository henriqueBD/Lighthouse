class_name Global
extends Node

#region global const

# Collision Layer
const player_collision_layer: int = 2

# Light mask
const shadow_light_mask: int = 4

# Z-Index
const pop_up_z_index: int = 5
const player_z_index: int = 1
const shadow_z_index: int = -1
const floor_z_index: int = -2

#endregion

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
var _events: Dictionary[String, Array]

#region static

static func is_same_type(x: Variant, y: Variant) -> bool:
	if typeof(x) != typeof(y):
		return false
	
	if typeof(x) == TYPE_OBJECT:
		if x == null or y == null:
			return x == y
		
		return x.get_class() == y.get_class() and x.get_script() == y.get_script()
	
	assert(false, "?????????")
	return true

#endregion

func set_node_active(node: Node, val: bool) -> void:
	#NEVER put a EventListner or a Action here
	if node is Interactable:
		node.active = val
	elif node is Transition:
		node.set_active(val)
	elif node is CollisionShape2D:
		node.set_deferred("disabled", not val)
	elif node is Sprite2D:
		node.visible = val
	
	for child: Node in node.get_children():
		set_node_active(child, val)

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

func register_unique_entity(unique_name: String, node: Node) -> void:
	assert(not _entities.has(unique_name), "Name " + unique_name + " is not unique")
	_entities[unique_name] = node

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

func get_local_var(variable: GameVariable) -> Variant:
	return main_node.curr_map.get_var(variable)

func local_var_exists(variable: GameVariable) -> bool:
	return main_node.curr_map.var_exists(variable)

func set_local_var(variable: GameVariable, value: Variant) -> void:
	main_node.curr_map.save_var(variable, value)

func toggle_is_playing_cutscene(val: bool) -> void:
	_is_playing_cutscene = val

func subscribe_to_event(event: GameVariable, node: EventListener) -> void:
	var id: String = event.get_ID()
	if _events.has(id):
		_events[id].append(node)
	else:
		var new_array: Array[EventListener] = [node]
		_events[id] = new_array

func emit_event(event: GameVariable) -> void:
	var arr: Array[EventListener] = _events.get(event.get_ID())
	if arr:
		for node: EventListener in arr:
			node.execute()

#endregion

func toggle_listen_input(value: bool) -> void:
	set_process_unhandled_input(value)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Interact"):
		interact_pressed.emit()

func change_scene(new_scene_path: String, spawn_name: String) -> void:
	_events.clear()
	if not ResourceLoader.exists(new_scene_path):
		assert(false, "Missing scene at: " + new_scene_path)
		return
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

func play_sound(to_play: AudioStream) -> Signal:
	assert(to_play)
	if main_node.sfx_player.playing:
		main_node.sfx_player.stop()
		assert(false, "Unsupported playinf two sounds at once")
	main_node.sfx_player.stream = to_play
	main_node.sfx_player.play()
	return main_node.sfx_player.finished
