class_name Player
extends Node

const WALK_SPEED: float = 60.0

var _controller: Character
var _light: PointLight2D
var _UV_light: PointLight2D
var _lantern_on: bool
var _is_locked: bool

func _ready() -> void:
	_controller = $".."
	_light = %Light
	_UV_light = %UV_Light
	_light.enabled = false
	GameManager.set_player(self)

func _physics_process(_delta: float) -> void:
	if GameManager.is_player_locked():
		if not _is_locked:
			_controller.move_4_axis(Vector2.ZERO)
		_is_locked = true
		return
	
	_is_locked = false
	if Input.is_action_just_pressed("Toggle_lantern"): _toggle_lantern()
	
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	
	var direction: Vector2 = Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down"))
	_controller.move_4_axis(direction * WALK_SPEED)

func _toggle_lantern() -> void:
	_lantern_on = not _lantern_on
	_light.enabled = _lantern_on
