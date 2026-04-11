@icon("res://z_editor_only/transition_icon.svg")
class_name TransitionInput
extends Node2D

@export_file("*.tscn") var destination_path: String

func _ready() -> void:
	assert(get_parent() is Interactable)
	assert(not destination_path.is_empty(), 
	"No destination path set transition: " + get_parent().name)
	assert(ResourceLoader.exists(destination_path), 
	destination_path + " does not exist for: " + get_parent().name)
	
	var parent: Interactable = get_parent()
	assert(parent)
	if parent:
		parent.pop_up_type = Interactable.pop_up_texture.TRANSITION
		parent.interacted.connect(_trigger_transition, CONNECT_ONE_SHOT)

func _trigger_transition() -> void:
	for child: Node in get_children():
		if child is Sprite2D:
			child.frame = 1
			break
	GameManager.change_scene(destination_path, get_parent().name)
