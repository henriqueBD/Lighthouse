@icon("res://z_editor_only/cutscene_trigger_icon.svg")
class_name CutsceneData
extends Node

@export var one_shot: bool
@export var lock_player: bool = true
@export var cutscene: Cutscene

var _cursor: CutsceneCursor

func _ready() -> void:
	assert(cutscene != null, "No cutscene in object " + str(get_path()))
	
	var parent: Node = get_parent()
	if parent == null:
		assert(false, "CutsceneData must have a parent")
		return
	
	assert(owner is Place, "Owner must be of type Place")
	if one_shot and owner is Place:
		assert(owner is Place)
		if owner.var_exists(_get_save_id()):
			parent.queue_free()
			return
	
	if parent is Interactable:
		parent.pop_up_type = Interactable.pop_up_texture.DIALOGUE
		parent.interacted.connect(start_cutscene)
	elif parent is CutsceneTrigger:
		parent.trigged.connect(start_cutscene) 
	else:
		assert(false, "Parent is neither Interactable nor CutsceneTrigger.")

func _exit_tree() -> void:
	assert(not _cursor, "Tried to unload active cutscene " + str(get_path()))
	if _cursor:
		finish_cutscene(null)

func start_cutscene() -> void:
	assert(_cursor == null, "Two cutscenes active" + str(get_path()))
	if cutscene == null or _cursor != null: 
		return
	
	assert(owner is Place, "What the fuck")
	if one_shot and owner is Place:
		owner.save_var(_get_save_id(), true)
	
	GameManager.toggle_is_playing_cutscene(true)
	_cursor = CutsceneCursor.new()
	_cursor.cutscene_ended.connect(finish_cutscene)
	_cursor.start_cutscene(cutscene, self)

func finish_cutscene(_reset_value: Cutscene) -> void:
	GameManager.toggle_is_playing_cutscene(false)
	_cursor = null
	
	if one_shot:
		var parent: Node = get_parent()
		if parent != null:
			parent.queue_free()

func _get_save_id() -> GameVariable:
	return GameVariable.create(str(owner.get_path_to(self)))
