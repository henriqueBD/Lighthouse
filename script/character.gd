class_name Character
extends CharacterBody2D

signal action_done

const WALK_SPEED: float = 60.0

const DIR_NONE: int = -1
const DIR_UP: int = 0
const DIR_DOWN: int = 1
const DIR_LEFT: int = 2
const DIR_RIGHT: int = 3

const WALK_TO_POINT_STATE: int = 1

const ANIM_IDLE: PackedStringArray = ["up_idle", "down_idle", "left_idle", "right_idle"]
const ANIM_WALK: PackedStringArray = ["up_walk", "down_walk", "left_walk", "right_walk"]

var _curr_direction: int = DIR_NONE
var _curr_state: int
var _target_location: Vector2

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	set_physics_process(false)
	assert(animation_player, "missing animation player")
	
	if OS.has_feature("debug"):
		for key: String in ANIM_IDLE:
			assert(animation_player.has_animation(key), "Animation missing: " + key)
		for key: String in ANIM_WALK:
			assert(animation_player.has_animation(key), "Animation missing: " + key)

func _physics_process(_delta: float) -> void:
	match _curr_state:
		0:
			assert(false, "invalid state")
			set_physics_process(false)
		WALK_TO_POINT_STATE:
			_walk_to_point_process()

##This method should be used inside a method called by _physics_process()
##Do not multiply direction by delta
func move_4_axis(direction: Vector2) -> void:
	var new_direction: int = _get_direction(direction)
	
	if new_direction == DIR_NONE:
		if _curr_direction != DIR_NONE:
			animation_player.play(ANIM_IDLE[_curr_direction])
			_curr_direction = new_direction
	else:
		if new_direction != _curr_direction:
			_curr_direction = new_direction
			animation_player.play(ANIM_WALK[new_direction])
		velocity = direction
		move_and_slide()

func turn_towards_unique(unique_entity: String) -> void:
	turn_to_point(GameManager.get_unique_entity_parent(unique_entity).global_position)

func turn_to_point(global_point: Vector2) -> void:
	_curr_direction= _get_direction_towards(global_point)
	animation_player.play(ANIM_IDLE[_curr_direction])

func walk_to_marker(marker_name: String) -> void:
	var targer_marker: Marker = GameManager.get_marker(marker_name)
	if not targer_marker:
		assert(false)
		return
	_curr_state = WALK_TO_POINT_STATE
	_target_location = targer_marker.global_position
	set_physics_process(true)

func walk_in_direction(direction: Vector2) -> bool:
	if direction == Vector2.ZERO:
		assert(false)
		return false
	_curr_state = WALK_TO_POINT_STATE
	_target_location = global_position + direction
	set_physics_process(true)
	return true

func step() -> void:
	print("step")

func _walk_to_point_process() -> void:
	if global_position.is_equal_approx(_target_location) or get_slide_collision_count() > 0:
		action_done.emit()
		set_physics_process(false)
	move_4_axis((_target_location - global_position).normalized() * WALK_SPEED)

func _get_direction(dirention: Vector2) -> int:
	if dirention.x != 0:
		return DIR_RIGHT if dirention.x > 0 else DIR_LEFT
	elif dirention.y != 0:
		return DIR_DOWN if dirention.y > 0 else DIR_UP
	else:
		return DIR_NONE

func _get_direction_towards(global_point: Vector2) -> int:
	var diff: Vector2 = global_point - global_position
	
	if absf(diff.x) > absf(diff.y):
		return DIR_RIGHT if diff.x > 0.0 else DIR_LEFT
	else:
		return DIR_DOWN if diff.y > 0.0 else DIR_UP
