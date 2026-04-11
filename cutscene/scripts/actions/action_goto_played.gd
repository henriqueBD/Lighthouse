##Conditional jump based if the cutscene played atleast once
class_name GotoPlayed
extends CutsceneAction

@export var jump_to_if_true: Cutscene #extends Resource

func execute(_context: Node) -> void:
	assert(false, "no")
	action_ended.emit()

func evaluate() -> Cutscene:
	var id: GameVariable = GameVariable.create(_get_unique_id())
	
	if GameManager.local_var_exists(id):
		return jump_to_if_true
	else:
		GameManager.set_local_var(id, null)
		return null

func _get_unique_id() -> String:
	assert(not jump_to_if_true.resource_path.is_empty())
	return str(jump_to_if_true.resource_path)
