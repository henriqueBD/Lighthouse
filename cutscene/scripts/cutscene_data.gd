@icon("res://z_editor_only/cutscene_trigger_icon.svg")
class_name CutsceneData
extends Node

@export var one_shot: bool
@export var lock_player: bool
@export var cutscene: Cutscene

var _cursor: CutsceneCursor

func _ready() -> void:
	assert(cutscene, "No cutscene in object " + str(get_path()))
	
	var parent: Node = get_parent()
	if not parent: 
		assert(false)
		return
	
	assert(owner is Place)
	if owner is Place:
		var raw_id: int = cutscene.get_rid().get_id()
		var played: Variant = owner.get_var("%x" % raw_id)
		if played:
			parent.queue_free()
	
	if parent is Interactable:
		parent.interacted.connect(start_cutscene)
	else:
		assert(false)

func start_cutscene() -> void:
	assert(not _cursor, "two cutscenes actives")
	
	if not cutscene or _cursor: return
	
	assert(owner is Place)
	if owner is Place:
		var raw_id: int = cutscene.get_rid().get_id()
		owner.save_var("%x" % raw_id, true)
	
	_cursor = CutsceneCursor.new()
	_cursor.start_cutscene(cutscene)
	_cursor.cutscene_ended.connect(finish_cutscene)

func finish_cutscene(_reset_value: Cutscene) -> void:
	_cursor = null
	
	if one_shot:
		var parent: Node = get_parent()
		if parent:
			parent.queue_free()

func _str_to_rid(hex_string: String) -> RID:
	var raw_id: int = hex_string.hex_to_int()
	return rid_from_int64(raw_id)
