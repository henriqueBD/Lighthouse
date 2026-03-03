class_name PickableObject
extends Node

enum TYPE{
	test
}

@export var item: TYPE
@export var queue_free_on_pick: bool

func pick() -> void:
	print("picked item")
	if queue_free_on_pick:
		queue_free()
