#Conditional jump based on global bool
class_name GotoBool
extends CutsceneAction

@export var varible: GameVariable
@export var jump_to_if_true: Cutscene

func execute(_context: Node) -> void:
	assert(false, "no")
	action_ended.emit()

func evaluate() -> Cutscene:
	assert(varible)
	
	if varible:
		varible.initialize()
		var target: Variant = GameManager.main_node.curr_map.get_var(varible)
		if target != null:
			return jump_to_if_true
	
	return null
