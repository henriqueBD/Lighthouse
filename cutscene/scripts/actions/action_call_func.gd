class_name CallFunc
extends CutsceneAction

enum FuncName{
	UNASSIGNED,
	FADE_OUT_SCREEN,
	FADE_IN_SCREEN,
}

@export var function: FuncName

func execute(_context: Node) -> void:
	assert(function != FuncName.UNASSIGNED)
	
	match function:
		FuncName.UNASSIGNED:
			assert(false, "no function assigned")
			_end()
		FuncName.FADE_OUT_SCREEN:
			_fade_out_screen()
		FuncName.FADE_IN_SCREEN:
			_fade_in_screen()
		_:
			assert(false, "Uninplemented function " + FuncName.keys()[function])
			action_ended.emit()

func _end() -> void:
	action_ended.emit()

func _fade_out_screen() -> void:
	await GameManager.main_node.fade_out_screen()
	_end()

func _fade_in_screen() -> void:
	await GameManager.main_node.fade_in_screen()
	_end()
