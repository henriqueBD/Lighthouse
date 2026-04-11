class_name ManagerMainNode
extends Node2D

@export_file("*.tscn") var start_scene: String

const DIALOGUE_BOX_INFO: PackedScene = preload("res://scene/important/dialogue_box.tscn")
const DIALOGUE_BOX_CHAR: PackedScene = preload("res://scene/important/dialogue_box_char.tscn")
const SCREEN_TRANSITION: PackedScene = preload("res://scene/important/screen_transition.tscn")

var curr_map: Place
var time_manager: TimeManager
var sfx_player: AudioStreamPlayer

var _screen_transition: ScreenTransition
var _canvas_layer: CanvasLayer
var _canvas_layer_subviewport: CanvasLayer
var _dialogue_info_instance: DialogueBox
var _dialogue_char_instance: DialogueBox
var _game_subviewport: SubViewport

func _ready() -> void:
	GameManager.set_main_node(self)
	
	sfx_player = AudioStreamPlayer.new()
	add_child(sfx_player)
	
	_canvas_layer = %CanvasLayer
	assert(_canvas_layer)
	_game_subviewport = %SubViewport
	assert(_game_subviewport)
	_canvas_layer_subviewport = %CanvasLayerSubviewport
	assert(_canvas_layer_subviewport)
	time_manager = %TimeManager
	assert(time_manager)
	curr_map = %CurrMap
	assert(curr_map)
	
	#Dialogue initialization
	_dialogue_info_instance = DIALOGUE_BOX_INFO.instantiate()
	_dialogue_info_instance.hide()
	_canvas_layer.add_child(_dialogue_info_instance)
	
	_dialogue_char_instance = DIALOGUE_BOX_CHAR.instantiate()
	_dialogue_char_instance.hide()
	_canvas_layer.add_child(_dialogue_char_instance)
	
	assert(_dialogue_info_instance and _dialogue_char_instance)
	
	#Screen transition
	_screen_transition = SCREEN_TRANSITION.instantiate()
	assert(_screen_transition)
	_screen_transition.hide()
	add_child(_screen_transition)
	
	assert(start_scene)
	GameManager.change_scene(start_scene, "Start")

#region Dialogue

func start_dialogue_info(raw_dialogue: PackedStringArray, close_on_end: bool) -> Signal:
	_dialogue_info_instance.start_dialogue(raw_dialogue, close_on_end)
	return _dialogue_info_instance.dialogue_ended

func start_dialogue_character(raw_dialogue: PackedStringArray, portraits: Array[Texture2D], close_on_end: bool) -> Signal:
	_dialogue_char_instance.start_dialogue(raw_dialogue, close_on_end)
	_dialogue_char_instance.start_dialogue_character(portraits)
	return _dialogue_char_instance.dialogue_ended

#TODO: Assert that every portrait has the same dimensions
#TODO: Would be nice to support animated portrairs (new_portrait passed as as sprite frames)
func change_dialogue_portrait(new_portrait: Texture2D) -> void:
	assert(new_portrait)
	#_active_dialogue_portrait.texture = new_portrait

#endregion

func add_node_subviewport(to_add: Node) -> void:
	_canvas_layer_subviewport.add_child(to_add)

func fade_out_screen() -> Signal:
	_screen_transition.show()
	return _screen_transition.fade_out()

func fade_in_screen() -> Signal:
	var finished: Signal = _screen_transition.fade_in()
	finished.connect(_screen_transition.hide, CONNECT_ONE_SHOT)
	return finished

func change_scene(new_scene_path: String, spawn_name: String, player: Node) -> void:
	await fade_out_screen()
	
	player.reparent(self)
	curr_map.queue_free()
	_change_scene_deffered.call_deferred(new_scene_path, spawn_name, player)

func _change_scene_deffered(new_scene_path: String, spawn_name: String, player: Node) -> void:
	assert(player)
	
	assert(ResourceLoader.exists(new_scene_path), "Path does not exist: " + new_scene_path)
	var instanciated_scene: Node = load(new_scene_path).instantiate()
	assert(instanciated_scene is Place, "Must be of type Place: " + new_scene_path)
	curr_map = instanciated_scene
	_game_subviewport.add_child(curr_map)
	
	var entities_node: Node2D = curr_map.get_node_or_null("%Entities")
	if entities_node:
		entities_node.z_index = 1 ##TODO: Make this global
		entities_node.y_sort_enabled = true
		player.reparent(entities_node)
	else:
		player.reparent(curr_map)
	
	#Get spawn point
	var player_spawn: Vector2 = Vector2.ZERO
	var res: Node2D = curr_map.get_node_or_null(spawn_name)
	if res:
		assert(res is Transition or res is Interactable)
		if res is Transition:
			player_spawn = res.global_position
		elif res is Interactable:
			for tmp: Node in res.get_children():
				if tmp is TransitionInput: 
					player_spawn = tmp.global_position
					break
	else:
		assert(false, "No spawn in" + new_scene_path + " For transition" + spawn_name)
		#Panic, Return first valid spawn point
		var spawn_node: Array[Node] = curr_map.find_children("*", "Transition", true) 
		if spawn_node.is_empty():
			spawn_node = curr_map.find_children("*", "TransitionInput", true)
		if not spawn_node.is_empty():
			player_spawn = spawn_node[0].global_position
	#----=====-----
	
	GameManager.player_parent.global_position = player_spawn
	
	fade_in_screen().connect(GameManager.fade_in_finished, CONNECT_ONE_SHOT)
