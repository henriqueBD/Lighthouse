class_name ManagerMainNode
extends Node2D

const DIALOGUE_BOX: PackedScene = preload("res://main_scene/dialogue_box.tscn")

var _canvas_layer: CanvasLayer
var _active_dialogue_box: Control
var _active_dialogue_box_label: Label

func _ready() -> void:
	GameManager.set_main_node(self)
	
	_canvas_layer = $CanvasLayer
	assert(_canvas_layer)
	
	_active_dialogue_box = DIALOGUE_BOX.instantiate()
	_active_dialogue_box.hide()
	_active_dialogue_box_label = _active_dialogue_box.get_node("%Label")
	assert(_active_dialogue_box_label)
	
	_canvas_layer.add_child(_active_dialogue_box)

func show_dialogue_box() -> void:
	_active_dialogue_box.show()

## Changes the label text and set label.visible_characters = 0
func change_dialogue_text(new_text: String) -> void:
	_active_dialogue_box_label.text = new_text
	_active_dialogue_box_label.visible_characters = 0

## Makes the next char visible and returns if all chars are visible
func show_next_char() -> bool:
	_active_dialogue_box_label.visible_characters += 1
	return _active_dialogue_box_label.visible_ratio == 1.0

func hide_dialogue_box() -> void:
	_active_dialogue_box.hide()
