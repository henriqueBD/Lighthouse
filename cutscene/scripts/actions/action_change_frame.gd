class_name ChangeFrame
extends CutsceneAction

@export var new_frame: int

func execute(context: Node) -> void:
	assert(context is Sprite2D)
	if context is Sprite2D:
		assert(new_frame < (context.hframes * context.vframes), "Invalid frame index")
		context.frame = new_frame
	
	action_ended.emit()
