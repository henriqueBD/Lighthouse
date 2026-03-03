class_name Player
extends Node

@export var walk_speed: float = 60.0

var _controller: Character
var _light: PointLight2D
var _lantern_on: bool

func _ready() -> void:
	_controller = $".."
	_light = %Light
	_light.enabled = false

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("Toggle_lantern"): _toggle_lantern()
	
	var direction: Vector2 = Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down"))
	_controller.move_4_axis(direction * walk_speed)

func _toggle_lantern() -> void:
	_lantern_on = not _lantern_on
	_light.enabled = _lantern_on
