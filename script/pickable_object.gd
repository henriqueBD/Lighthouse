extends Sprite2D

enum TYPE{
	test
}

@export var item: TYPE

func pick() -> void:
	print("picked item")
	queue_free()
