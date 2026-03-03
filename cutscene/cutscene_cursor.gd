class_name CutsceneCursor
extends Object

signal cutscene_ended(reset_cutscene: Cutscene)

var _count: int
var _cutscene: Cutscene
var _current_action: CutsceneAction

func start_cutscene(start: Cutscene) -> void:
	_count = -1
	_cutscene = start
	_advance()
	_execute()

func _execute() -> void:
	_current_action.action_ended.connect(_on_action_ended, CONNECT_ONE_SHOT)
	_current_action.execute()

func _advance() -> void:
	_count += 1
	if _count >= _cutscene.actions.size():
		_current_action = null
	else:
		_current_action = _cutscene.actions[_count]
		if _current_action is GotoBool:
			var evaluated: Cutscene = _current_action.evaluate()
			if evaluated: start_cutscene.call_deferred(evaluated)

func _on_action_ended() -> void:
	_advance()
	
	if not _current_action:
		cutscene_ended.emit(null)
		return
	
	_execute.call_deferred()
