class_name ManagerMainNode
extends Node2D

const DIALOGUE_BOX_INFO: PackedScene = preload("res://main_scene/dialogue_box.tscn")
const DIALOGUE_BOX_CHAR: PackedScene = preload("res://main_scene/dialogue_box_char.tscn")

var _canvas_layer: CanvasLayer
var _info_instance: Control
var _char_instance: Control
var _active_dialogue_box: Control
var _active_dialogue_portrait: TextureRect
var _active_dialogue_box_label: Label

func _ready() -> void:
	GameManager.set_main_node(self)
	
	_canvas_layer = $CanvasLayer
	assert(_canvas_layer)
	
	_info_instance = DIALOGUE_BOX_INFO.instantiate()
	_info_instance.hide()
	_canvas_layer.add_child(_info_instance)
	
	_char_instance = DIALOGUE_BOX_CHAR.instantiate()
	_char_instance.hide()
	_canvas_layer.add_child(_char_instance)
	_active_dialogue_portrait = _char_instance.get_node("%Portrait")
	assert(_active_dialogue_portrait)
	
	assert(_info_instance and _char_instance)

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
