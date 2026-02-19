class_name Player
extends Node

@export var walk_speed: float

@onready var controller: Character = $".."

func _physics_process(_delta: float) -> void:
	
	var direction: Vector2 = Vector2.ZERO
	
	direction.x += Input.get_axis("ui_left", "ui_right")
	direction.y += Input.get_axis("ui_up", "ui_down")
	
	controller.move_4_axis(walk_speed * direction.normalized())
