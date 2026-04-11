class_name EmitEvent
extends CutsceneAction

@export var event: GameVariable

func execute(_context: Node) -> void:
	assert(event, "No event set for " + str(_context.get_path()))
	
	if event:
		GameManager.emit_event(event)
	
	action_ended.emit()
