class_name ToggleActive
extends CutsceneAction

@export var target: NodePath
@export var active: bool

func execute(context: Node) -> void:
	var target_node: Node = context.get_node_or_null(target)
	if not target_node:
		assert(false, "No node " + str(target))
		action_ended.emit()
		return
	
	if target_node is Interactable:
		target_node.set_active(active)
	else:
		assert(false, "Invalid type")
	
	action_ended.emit()
