class_name Transition
extends Area2D

@export_file("*.tscn") var destination_path: String
@export var transition_name: String

var spawn_point: Node2D
var active: bool

func _ready() -> void:
	GameManager.register_spawn_point(self)
	collision_mask = 2  ##TODO: MAKE THIS GLOBAL
	active = true
	spawn_point = $Node2D
	body_entered.connect(_player_entered, CONNECT_ONE_SHOT)
	assert(spawn_point)
	assert(ResourceLoader.exists(destination_path), destination_path + " does not exist")

func _player_entered(_player: Node2D) -> void:
	if not ResourceLoader.exists(destination_path) or not active: return
	GameManager.change_scene(load(destination_path), transition_name)
