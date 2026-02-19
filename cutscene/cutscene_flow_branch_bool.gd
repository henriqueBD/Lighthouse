class_name CutsceneFlowBranchBool
extends CutsceneFlow

@export var value_to_check: GameManager.global_variables_bool
@export var next_if_true: CutsceneFlow
@export var next_if_false: CutsceneFlow

func cursor_arrived() -> void:
	pass

func should_advance() -> bool:
	return true

func get_action_finish_signal() -> Signal:
	assert(false, "This should not happen")
	return Signal()

func execute_action() -> void:
	assert(false, "This should not happen")

func get_next() -> CutsceneFlow:
	if GameManager.bool_is_active(value_to_check):
		return next_if_true
	else:
		return next_if_false
