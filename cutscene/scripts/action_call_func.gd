class_name CallFunc
extends CutsceneAction

enum FuncName{
	UNASSIGNED,
	FADE_SCREEN,
	WAIT,
	TELEPORT_ENTITY_TO_MARKER,
	INCREMENT_TIME,
}

@export var function: FuncName
@export var args: Array

func execute() -> void:
	assert(function != FuncName.UNASSIGNED)
	
	match function:
		FuncName.UNASSIGNED:
			assert(false, "no function assigned")
			_end()
		FuncName.FADE_SCREEN:
			if args and args.size() == 1 and args[0] is bool:
				_fade_screen(args[0])
			else: assert(false)
		FuncName.WAIT:
			if args and args.size() == 1 and args[0] is float:
				_wait(args[0])
			else: assert(false)
		FuncName.TELEPORT_ENTITY_TO_MARKER:
			_teleport_entity_to_marker()
		FuncName.INCREMENT_TIME:
			_increment_time()
		_:
			assert(false, "Uninplemented function " + FuncName.keys()[function])

func _end() -> void:
	action_ended.emit()

func _fade_screen(fade_out: bool) -> void:
	var finished: Signal
	if fade_out:
		finished = GameManager.main_node.fade_out_screen()
	else:
		finished = GameManager.main_node.fade_in_screen()
	finished.connect(_end, CONNECT_ONE_SHOT)

func _wait(time_sec: float) -> void:
	assert(time_sec > 0.1)
	time_sec = max(time_sec, 0.1)
	GameManager.create_timer(time_sec).connect(_end, CONNECT_ONE_SHOT)

func _teleport_entity_to_marker() -> void:
	if args and args.size() == 2 and args[0] is String and args[1] is String:
		GameManager.teleport_entity_to_marker(args[0], args[1])
	else:
		assert(false)
	_end()

func _increment_time() -> void:
	var time_manager: TimeManager = GameManager.main_node.time_manager
	if args.size() == 1 and args[0] is float:
		time_manager.increment_time_smooth(args[0], -1)
	elif args.size() == 2 and args[0] is float and args[1] is float:
		time_manager.increment_time_smooth(args[0], args[1])
	else:
		assert(false, str(args))
	_end()
