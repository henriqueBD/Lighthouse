class_name CutsceneTrigger
extends Node

@export var lock_player: bool
@export var cutscene: Cutscene

var _cursor: CutsceneCursor

func _ready() -> void:
	assert(cutscene, "No cutscene in object " + _get_grandparent_name())
	
	var parent: Node2D = get_parent()
	if not parent: 
		assert(false)
		return
	
	if parent is Interactable:
		parent.interacted.connect(start_cutscene)
	else:
		assert(false)

func start_cutscene() -> void:
	assert(not _cursor, "two cutscenes actives")
	
	if not cutscene or _cursor: return
	
	_cursor = CutsceneCursor.new()
	_cursor.start_cutscene(cutscene)
	_cursor.cutscene_ended.connect(finish_cutscene)

func finish_cutscene(reset_value: Cutscene) -> void:
	if reset_value:
		cutscene = reset_value
	
	_cursor = null
	print("cutscene_ended")

func _get_grandparent_name() -> String:
	var parent: Node = get_parent()
	if not parent: return "NULL"
	parent = parent.get_parent()
	if not parent: return "NULL"
	return parent.name
