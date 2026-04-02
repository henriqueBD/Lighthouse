class_name TextBoxCharacter
extends TextBox

@export var portraits: Array[Texture2D]

#Remember to also change the info dialogue variation
func execute(_context: Node) -> void:
	if not dialogue:
		assert(false)
		action_ended.emit()
		return
	assert(_vibe_check_dialogue(), str(dialogue))
	_count = 0
	GameManager.main_node.show_character_dialogue_box(portraits[0])
	GameManager.main_node.change_dialogue_text(_parse_text(dialogue[0]))
	GameManager.toggle_listen_input(true)
	GameManager.interact_pressed.connect(_on_input_pressed)
	GameManager.set_process_func(_process)

func _continue_dialogue() -> void:
	super()
	if _count >= portraits.size():
		return
	if portraits[_count]:
		GameManager.main_node.change_dialogue_portrait(portraits[_count])
