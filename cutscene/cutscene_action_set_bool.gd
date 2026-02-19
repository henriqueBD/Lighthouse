class_name CutsceneActionSetBool
extends CutsceneAction

@export var key: GameManager.global_variables_bool
@export var value: bool

func execute() -> void:
	GameManager.bool_set(key, value)
	action_ended.emit()
