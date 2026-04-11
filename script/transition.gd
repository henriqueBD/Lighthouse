@icon("res://z_editor_only/transition_icon.svg")
class_name Transition
extends Area2D

@export_file("*.tscn") var destination_path: String
#@export_enum("unassigned", "north", "south", "west", "east") var direction: int

var active: bool

func set_active(val: bool) -> void:
	active = val

func _ready() -> void:
	collision_mask = 2  ##TODO: MAKE THIS GLOBAL
	active = true
	
	body_entered.connect(_player_entered, CONNECT_ONE_SHOT)
	assert(not destination_path.is_empty(), "No destination path set for transition: " + name)
	assert(ResourceLoader.exists(destination_path), destination_path + " does not exist for: " + name)

func _player_entered(_player: Node2D) -> void:
	if not active: return
	for child: Node in get_children():
		if child is Sprite2D:
			child.frame = 1
			break
	GameManager.change_scene(destination_path, name)

func _direction_to_vector(_direction: int) -> Vector2:
	match _direction:
		0: return Vector2.UP
		1: return Vector2.DOWN
		2: return Vector2.LEFT
		3: return Vector2.RIGHT
	return Vector2.ZERO
