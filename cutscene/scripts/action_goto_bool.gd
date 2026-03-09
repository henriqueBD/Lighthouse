#Conditional jump based on global bool
class_name GotoBool
extends CutsceneAction

@export var check: GameManager.global_variables_bool
@export var jump_to_if_true: Cutscene 

func execute() -> void:
	assert(false, "no")
	action_ended.emit()

func evaluate() -> Cutscene:
	if GameManager.bool_is_active(check):
		return jump_to_if_true
	else:
		return null
