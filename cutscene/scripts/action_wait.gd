class_name Wait
extends CutsceneAction

@export var wait_time_sec: float

func execute() -> void:
	assert(wait_time_sec > 0.0, "Invalid time: " + str(wait_time_sec))
	if wait_time_sec > 0.0:
		await GameManager.count_down(wait_time_sec)
	action_ended.emit()
