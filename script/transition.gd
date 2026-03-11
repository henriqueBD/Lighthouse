@icon("res://z_editor_only/transition_icon.svg")
class_name Transition
extends Area2D

@export_file("*.tscn") var destination_path: String
@export var transition_name: String
@export_enum("north", "south", "west", "east") var direction: int

var spawn_point: Node2D
var active: bool

var _animated_sprite: Sprite2D

func _ready() -> void:
	GameManager.register_spawn_point(self)
	collision_mask = 2  ##TODO: MAKE THIS GLOBAL
	active = true
	spawn_point = $Node2D
	
	for child: Node in get_children():
		if child is Sprite2D: _animated_sprite = child
	
	body_entered.connect(_player_entered, CONNECT_ONE_SHOT)
	assert(spawn_point, "no spawn point for transition: " + transition_name)
	assert(not destination_path.is_empty(), "No destination path set for transition: " + transition_name)
	assert(ResourceLoader.exists(destination_path), destination_path + " does not exist for transition: " + transition_name)

func _player_entered(_player: Node2D) -> void:
	if not ResourceLoader.exists(destination_path) or not active: return
	if _animated_sprite:
		_animated_sprite.frame = 1
	GameManager.change_scene(load(destination_path), transition_name)

func _direction_to_vector(_direction: int) -> Vector2:
	match _direction:
		0: return Vector2.UP
		1: return Vector2.DOWN
		2: return Vector2.LEFT
		3: return Vector2.RIGHT
	return Vector2.ZERO
