##When playing the cutscene with the same trigger, it will start at reset_value
class_name CutsceneFlowSetReset
extends CutsceneFlow

@export var reset_value: CutsceneFlow

func cursor_arrived() -> void:
	assert(reset_value, "no reset value")

func should_advance() -> bool:
	return true

func get_action_finish_signal() -> Signal:
	assert(false, "This should not happen")
	return Signal()

func execute_action() -> void:
	assert(false, "This should not happen")

func get_next() -> CutsceneFlow:
	return null
