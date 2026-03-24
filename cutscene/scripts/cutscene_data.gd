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
		var save_id: String = _get_save_id()
		var played: Variant = owner.get_var(save_id)
		
		if played:
			parent.queue_free()
			return 
	
	if parent is Interactable:
		parent.interacted.connect(start_cutscene)
	elif parent is CutsceneTrigger:
		parent.trigged.connect(start_cutscene) 
	else:
		assert(false, "Parent is neither Interactable nor CutsceneTrigger.")

func start_cutscene() -> void:
	assert(_cursor == null, "Two cutscenes active" + str(get_path()))
	if cutscene == null or _cursor != null: 
		return
	
	assert(owner is Place, "What the fuck")
	if one_shot and owner is Place:
		var save_id: String = _get_save_id()
		owner.save_var(save_id, true)
	
	GameManager.toggle_is_playing_cutscene(true)
	_cursor = CutsceneCursor.new()
	_cursor.cutscene_ended.connect(finish_cutscene)
	_cursor.start_cutscene(cutscene)

func finish_cutscene(_reset_value: Cutscene) -> void:
	GameManager.toggle_is_playing_cutscene(false)
	_cursor = null
	
	if one_shot:
		var parent: Node = get_parent()
		if parent != null:
			parent.queue_free()

func _get_save_id() -> String:
	const prime: int = 16777619
	var text: String = str(owner.get_path_to(self))
	var hash_res: int = 2166136261
	# FNV prime (32-bit)
	var bytes: PackedByteArray = text.to_utf8_buffer()
	
	for b: int in bytes:
		hash_res = hash_res ^ b
		hash_res = (hash_res * prime) & 0xFFFFFFFF
	
	bytes.resize(4)
	bytes.encode_u32(0, hash_res)
	#TODO: Replaces the dangerous filename characters with safe ones
	#return Marshalls.raw_to_base64(bytes).trim_suffix("==").replace("/", "_").replace("+", "-")
	return Marshalls.raw_to_base64(bytes).trim_suffix("==")

func _exit_tree() -> void:
	assert(not _cursor, "Tried to unload active cutscene " + str(get_path()))
