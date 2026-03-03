class_name SetBool
extends CutsceneAction

@export var key: GameManager.global_variables_bool
@export var value: bool
@export var next: CutsceneAction 

func execute() -> void:
	GameManager.bool_set(key, value)
	action_ended.emit()
