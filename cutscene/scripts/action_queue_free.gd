class_name QueueFree
extends CutsceneAction

@export var target: NodePath

func execute(context: Node) -> void:
	var target_node: Node = context.get_node(target)
	if not target_node:
		assert(false, "No nude " + str(target))
		action_ended.emit()
		return
	target_node.queue_free()
	action_ended.emit()
