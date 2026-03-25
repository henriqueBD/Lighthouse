#Conditional jump based on global bool
class_name GotoBool
extends CutsceneAction

@export var var_name: String
@export var jump_to_if_true: Cutscene #extends Resource

func execute(context: Node) -> void:
	assert(false, "no")
	action_ended.emit()

func evaluate() -> Cutscene:
	assert(var_name and not var_name.is_empty())
	
	var target: Variant = GameManager.main_node.curr_map.get_var(var_name)
	if target != null:
		return jump_to_if_true
	
	return null
