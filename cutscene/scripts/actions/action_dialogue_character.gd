class_name TextBoxCharacter
extends TextBox

@export var portraits: Array[Texture2D]

#Remember to also change the info dialogue variation
func execute(_context: Node) -> void:
	if not dialogue:
		assert(false)
		action_ended.emit()
		return
	
	var finished_signal: Signal = (
		GameManager.main_node.start_dialogue_character(
			dialogue, portraits, close_dialogue_box_on_end
		)
	)
	
	await finished_signal
	
	action_ended.emit()
