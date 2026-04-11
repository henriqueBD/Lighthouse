class_name CreateVar
extends CutsceneAction

@export var variable: GameVariable

func execute(_context: Node) -> void:
	if not variable:
		assert(false, "No variable at " + str(_context.get_path()))
		action_ended.emit()
		return
	
	GameManager.set_local_var(variable, null)
	action_ended.emit()
