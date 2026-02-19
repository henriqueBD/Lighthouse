class_name CutsceneFlowLinear
extends CutsceneFlow

@export var actions: Array[CutsceneAction]
@export var next: CutsceneFlow

var _initialized: bool = false
var _count: int

func cursor_arrived() -> void:
	assert(actions.size() > 0)
	_initialized = true
	_count = 0

func should_advance() -> bool:
	return _count >= actions.size()

func get_action_finish_signal() -> Signal:
	return actions[_count].action_ended

func execute_action() -> void:
	_count += 1
	actions[_count - 1].execute()

func get_next() -> CutsceneFlow:
	if _count >= actions.size():
		_initialized = false
		return next
	else:
		return self
