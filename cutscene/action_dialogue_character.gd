class_name TextBoxCharacter
extends TextBox

@export var portraits: Array[Texture2D]

func execute() -> void:
	assert(portraits.size() == dialogue.size())
	_count = 0
	GameManager.start_dialogue(self, portraits[0])

func next_portrait() -> Texture2D:
	return portraits[_count - 1]
