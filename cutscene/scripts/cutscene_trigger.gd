@icon("res://z_editor_only/interactable_icon.svg")
class_name CutsceneTrigger
extends Area2D

signal trigged

@export var active: bool = true

func set_active(value: bool) -> void:
	active = value

func _ready() -> void:
	assert(_has_data_attached(), "Trigger does not have cutscene attached" + str(get_path()))
	collision_mask = 2 ##TODO: Make this global
	body_entered.connect(_player_entered)

func _player_entered(_body: Node2D) -> void:
	if active and not GameManager.is_player_locked():
		trigged.emit()

func _has_data_attached() -> bool:
	for child: Node in get_children():
		if child is CutsceneData:
			return true
	return false
