class_name Player
extends Node

@export var walk_speed: float = 60.0
@onready var controller: Character = $".."

## 180 means exactly 3 pixels per frame at 60 FPS (3 * 60)
#var straight_speed: float = 180.0 
#
## 120 means exactly 2 pixels per frame at 60 FPS (2 * 60)
#var diagonal_component: float = 120.0 
#
#func _physics_process(_delta: float) -> void:
	## Get raw input (-1, 0, or 1). Do NOT normalize here.
	#var direction: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	#
	#if direction != Vector2.ZERO:
		## Check if the player is pressing two keys at once (Diagonal)
		#if direction.x != 0.0 and direction.y != 0.0:
			#velocity.x = sign(direction.x) * diagonal_component
			#velocity.y = sign(direction.y) * diagonal_component
		#
		## Otherwise, it is straight movement
		#else:
			#velocity.x = sign(direction.x) * straight_speed
			#velocity.y = sign(direction.y) * straight_speed
			#
	#else:
		#velocity = Vector2.ZERO
		#
	#move_and_slide()

@onready var tmp: Node2D = GameManager.get_unique_entity_parent("stone")

func _physics_process(_delta: float) -> void:
	# Get raw input (-1, 0, or 1). Do NOT normalize here.
	var direction: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	controller.move_4_axis(direction * walk_speed)
