class_name QueueFree
extends CutsceneAction

func execute(context: Node) -> void:
	context.queue_free()
	action_ended.emit()
