class_name Character
extends CharacterBody2D

const DIR_NONE: int = -1
const DIR_UP: int = 0
const DIR_DOWN: int = 1
const DIR_LEFT: int = 2
const DIR_RIGHT: int = 3

const ANIM_IDLE: PackedStringArray = ["up_idle", "down_idle", "left_idle", "right_idle"]
const ANIM_WALK: PackedStringArray = ["up_walk", "down_walk", "left_walk", "right_walk"]

@export var can_turn: bool
@export var can_walk: bool

var curr_direction: int = DIR_NONE

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	assert(animation_player, "missing animation player")
	_vibe_check()

func _vibe_check() -> void:
	if can_turn:
		for key: String in ANIM_IDLE:
			assert(animation_player.has_animation(key), "Animation missing: " + key)
	
	if can_walk:
		for key: String in ANIM_WALK:
			assert(animation_player.has_animation(key), "Animation missing: " + key)

##This method should be used inside a method called by _physics_process()
##Do not multiply direction by delta
func move_4_axis(direction: Vector2) -> void:
	assert(can_walk, "this character is now allowed to move")
	
	#direction = ceil(direction)
	#
	#if abs(direction.x) != abs(direction.y):
		#print("different")
	
	var new_direction: int = get_direction(direction)
	
	if new_direction == DIR_NONE:
		if curr_direction != DIR_NONE:
			animation_player.play(ANIM_IDLE[curr_direction])
			curr_direction = new_direction
	else:
		if new_direction != curr_direction:
			curr_direction = new_direction
			animation_player.play(ANIM_WALK[new_direction])
		velocity = direction
		move_and_slide()
		sprite_2d.global_position = ceil(global_position)

func get_direction(dirention: Vector2) -> int:
	if dirention.x != 0:
		return DIR_RIGHT if dirention.x > 0 else DIR_LEFT
	elif dirention.y != 0:
		return DIR_DOWN if dirention.y > 0 else DIR_UP
	else:
		return DIR_NONE

func step() -> void:
	print("step")
