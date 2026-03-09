class_name TextBoxCharacter
extends TextBox

@export var portraits: Array[Texture2D]

func execute() -> void:
	assert(portraits.size() == dialogue.size())
	super()

func _continue_dialogue() -> void:
	super()
	GameManager.main_node.change_dialogue_portrait(portraits[_count])
