class_name IncrementTime
extends CutsceneAction

@export var increment: float
@export var custom_speed: float

func execute(_context: Node) -> void:
	GameManager.main_node.time_manager.increment_time_smooth(increment, custom_speed)
	action_ended.emit()
