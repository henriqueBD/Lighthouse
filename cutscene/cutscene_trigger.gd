class_name CutsceneTrigger
extends Node

@export var lock_player: bool
@export var cutscene: Cutscene

var _cursor: CutsceneCursor

func start_cutscene() -> void:
	assert(cutscene, "No cutscene")
	assert(not _cursor, "two cutscenes actives")
	
	if not cutscene: return
	
	_cursor = CutsceneCursor.new()
	_cursor.start_cutscene(cutscene)
	_cursor.cutscene_ended.connect(finish_cutscene)

func finish_cutscene(reset_value: Cutscene) -> void:
	if reset_value:
		cutscene = reset_value
	
	_cursor = null
	print("cutscene_ended")
