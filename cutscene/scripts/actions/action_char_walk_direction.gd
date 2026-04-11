class_name CharWalkDirection
extends CutsceneAction

@export var character_name: String
@export var direction: Vector2

func execute(_context: Node) -> void:
	var character: Character = GameManager.get_character(character_name)
	if not character:
		assert(false)
		action_ended.emit()
		return
	
	var can_continue: bool = character.walk_in_direction(direction)
	if can_continue:
		await character.action_done
	
	action_ended.emit()
