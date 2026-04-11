class_name TextBox
extends CutsceneAction

const DIALOGUE_SPEED_PER_CHAR: float = 0.04

@export_multiline var dialogue: PackedStringArray
@export var close_dialogue_box_on_end: bool = true

#Remember to also change the character dialogue variation
func execute(_context: Node) -> void:
	if not dialogue:
		assert(false)
		action_ended.emit()
		return
	
	var finished_signal: Signal = (
		GameManager.main_node.start_dialogue_info(dialogue, close_dialogue_box_on_end))
	
	await finished_signal
	
	action_ended.emit()
