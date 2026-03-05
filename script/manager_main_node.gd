class_name ManagerMainNode
extends Node2D

const DIALOGUE_BOX_INFO: PackedScene = preload("res://scene/dialogue_box.tscn")
const DIALOGUE_BOX_CHAR: PackedScene = preload("res://scene/dialogue_box_char.tscn")

var _canvas_layer: CanvasLayer
var _info_instance: Control
var _char_instance: Control
var _active_dialogue_box: Control
var _active_dialogue_portrait: TextureRect
var _active_dialogue_box_label: Label

var _game_subviewport: SubViewport

var _curr_map: Node

func _ready() -> void:
	GameManager.set_main_node(self)
	
	_canvas_layer = %CanvasLayer
	assert(_canvas_layer)
	_game_subviewport = %SubViewport
	assert(_game_subviewport)
	_curr_map = _game_subviewport.get_child(0)
	assert(_curr_map)
	
	#Dialogue initialization
	_info_instance = DIALOGUE_BOX_INFO.instantiate()
	_info_instance.hide()
	_canvas_layer.add_child(_info_instance)
	
	_char_instance = DIALOGUE_BOX_CHAR.instantiate()
	_char_instance.hide()
	_canvas_layer.add_child(_char_instance)
	_active_dialogue_portrait = _char_instance.get_node("%Portrait")
	assert(_active_dialogue_portrait)
	
	assert(_info_instance and _char_instance)

#region Dialogue

func show_dialogue_box(portrait: Texture2D) -> void:
	if portrait:
		_active_dialogue_box = _char_instance
		_active_dialogue_portrait.texture = portrait
	else:
		_active_dialogue_box = _info_instance
	
	_active_dialogue_box_label = _active_dialogue_box.get_node("%Label")
	assert(_active_dialogue_box_label)
	_active_dialogue_box.show()

func hide_dialogue_box() -> void:
	_active_dialogue_portrait.texture = null
	_active_dialogue_box.hide()

## Changes the label text and set label.visible_characters = 0
func change_dialogue_text(new_text: String) -> void:
	_active_dialogue_box_label.text = new_text
	_active_dialogue_box_label.visible_characters = 0

## Makes the next char visible and returns if all chars are visible
func show_next_char() -> bool:
	_active_dialogue_box_label.visible_characters += 1
	return _active_dialogue_box_label.visible_ratio == 1.0

#TODO: Assert that every portrait has the same dimensions
#TODO: Would be nice to support animated portrairs (new_portrait passed as as sprite frames)
func change_dialogue_portrait(new_portrait: Texture2D) -> void:
	assert(new_portrait)
	_active_dialogue_portrait.texture = new_portrait

#endregion

func change_scene(new_scene: PackedScene, spawn_name: String, player: Node) -> void:
	player.owner = null
	_curr_map.queue_free()
	_change_scene_deffered.call_deferred(new_scene, spawn_name, player)

func _change_scene_deffered(new_scene: PackedScene, spawn_location: String, player: Node) -> void:
	_curr_map = new_scene.instantiate()
	_game_subviewport.add_child(_curr_map)
	var objects_node: Node2D = _curr_map.get_node_or_null("%Entities")
	if objects_node:
		player.reparent(objects_node)
	else:
		player.reparent(_curr_map)
	var player_spawn: Transition = GameManager.get_spawn_point(spawn_location)
	assert(player_spawn)
	GameManager._player_parent.global_position = player_spawn.spawn_point.global_position
