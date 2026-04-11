@icon("res://z_editor_only/game_variable.svg")
class_name GameVariable
extends Resource

var _uid: int = -1

static func create(uid: String) -> GameVariable:
	var res: GameVariable = GameVariable.new()
	res._uid = uid.hash()
	return res

func initialize() -> void:
	assert(not resource_path.is_empty())
	_uid = ResourceLoader.get_resource_uid(resource_path)
	assert(_uid != -1)

func get_ID() -> String:
	assert(_uid != -1)
	return str(_uid)

func get_ID_int() -> int:
	return _uid
