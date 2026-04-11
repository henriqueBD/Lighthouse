class_name ToggleActive
extends CutsceneAction

@export var active: bool

func execute(context: Node) -> void:
	GameManager.set_node_active(context, active)
	action_ended.emit()
