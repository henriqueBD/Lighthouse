class_name SaveData
extends RefCounted

# Holds our nested folders. 
var _folders: Dictionary[String, Dictionary]

func _init() -> void:
	_folders = {}

func store_var(folder_name: String, variable: GameVariable) -> void:
	assert(not folder_name.is_empty(), "Path cannot be empty")
	_get_folder(folder_name)[variable.get_ID()] = variable

func get_var_or_null(folder_name: String, variable: GameVariable) -> Variant:
	assert(not folder_name.is_empty(), "Path cannot be empty")
	
	var folder: Dictionary = _get_folder(folder_name)
	var id: String = variable.get_ID()
	
	if folder.has(id):
		return folder[id].data
	
	return null

func var_exists(folder_name: String, variable: GameVariable) -> bool:
	assert(not folder_name.is_empty(), "Path cannot be empty")
	return _get_folder(folder_name).has(variable.get_ID())

func create_folder(name: String) -> void:
	assert(not name.is_empty())
	if not _folders.has(name):
		var new_folder: Dictionary[String, GameVariable] = {}
		_folders[name] = new_folder

func erase_folder(name: String) -> void:
	assert(_folders.has(name), "Invalid folder deletion: " + name)
	_folders.erase(name)

func _get_folder(folder_name: String) -> Dictionary[String, GameVariable]:
	assert(_folders.has(folder_name), "No folder with name " + folder_name)
	return _folders.get(folder_name, {})
