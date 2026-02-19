class_name CutsceneTrigger
extends Node

@export var lock_player: bool
@export var cutscene: CutsceneFlow

var _cursor: CutsceneCursor

func start_cutscene() -> void:
	assert(cutscene, "No cutscene")
	assert(not _cursor, "two cutscenes actives")
	
	_cursor = CutsceneCursor.new()
	_cursor.start(cutscene)
	_cursor.cutscene_ended.connect(finish_cutscene)

func finish_cutscene(reset_value: CutsceneFlow) -> void:
	
	if reset_value:
		cutscene = reset_value
	
	_cursor = null
	print("cutscene_ended")
