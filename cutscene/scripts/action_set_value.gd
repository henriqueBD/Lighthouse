class_name SetValue
extends CutsceneAction

##Local or global
@export var path: String
@export var value: Variant

func execute(_context: Node) -> void:
	GameManager.set_global_var(path, value)
	action_ended.emit()
