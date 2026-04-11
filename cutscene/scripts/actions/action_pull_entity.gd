class_name PullEntity
extends CutsceneAction

##Local or global
@export var entity_name: String

func execute(context: Node) -> void:
	if context is not Node2D:
		assert(false)
		action_ended.emit()
		return
	
	var object: Node2D = GameManager.get_unique_entity_parent(entity_name)
	if object:
		object.global_position = context.global_position
	
	action_ended.emit()
