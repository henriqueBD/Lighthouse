class_name CutsceneCursor
extends Object

signal cutscene_ended(reset_cutscene: CutsceneFlow)

var _current: CutsceneFlow
var _previous: CutsceneFlow

func start(start_point: CutsceneFlow) -> void:
	_current = start_point
	_current.cursor_arrived()
	_try_advance()
	_execute()

func _execute() -> void:
	var action_ended: Signal = _current.get_action_finish_signal()
	action_ended.connect(_on_action_ended, CONNECT_ONE_SHOT)
	_current.execute_action()

func _try_advance() -> void:
	while _current.should_advance():
		_previous = _current
		_current = _current.get_next()
		if not _current: break
		_current.cursor_arrived()

func _on_action_ended() -> void:
	_try_advance()
	
	if not _current:
		if _previous is CutsceneFlowSetReset:
			cutscene_ended.emit(_previous.reset_value)
		else:
			cutscene_ended.emit(null)
		return
	
	_execute()
