class_name SaveData
extends RefCounted

class Folder:
	extends RefCounted
	var items: Dictionary[String, Variant] = {}
	var subfolders: Dictionary[String, Folder] = {}

var root: Folder

func _init() -> void:
	root = Folder.new()

##Path before must be valid
func store_var(path: String, value: Variant) -> void:
	assert(value != null, "Value cannot be null")
	assert(not path.is_empty(), "Path cannot be empty")
	
	var split_path: PackedStringArray = _split_path(path)
	var target_folder: Folder = _get_folder(split_path[0])
	
	if target_folder:
		target_folder.items[split_path[1]] = value

func get_var(path: String) -> Variant:
	assert(not path.is_empty(), "Path cannot be empty")
	
	var split_path: PackedStringArray = _split_path(path)
	var target_folder: Folder = _get_folder(split_path[0])
	
	assert(target_folder.items.has(split_path[1]), "Item does not exist at path: " + path)
	return target_folder.items.get(split_path[1])

func create_folder(path: String) -> void:
	var split_path: PackedStringArray = _split_path(path)
	var parent_folder: Folder = _get_folder(split_path[0])
	var to_add_name: String = split_path[1]
	
	assert(parent_folder, "Could not find parent folder " + split_path[0])
	assert(not parent_folder.subfolders.has(to_add_name), "Folder already exists")
	if parent_folder and not parent_folder.subfolders.has(to_add_name):
		parent_folder.subfolders[to_add_name] = Folder.new()

func erase_folder(path: String) -> void:
	var split_path: PackedStringArray = _split_path(path)
	var parent_folder: Folder = _get_folder(split_path[0])
	var to_remove_name: String = split_path[1]
	
	assert(parent_folder, "Could not find parent folder " + split_path[0])
	assert(parent_folder.subfolders.has(to_remove_name), "Invalid deletion at: " + path)
	if parent_folder and parent_folder.subfolders.has(to_remove_name):
		parent_folder.subfolders.erase(to_remove_name)

func free_nodes() -> void:
	root.subfolders.clear()
	root.items.clear()

func _split_path(path: String) -> PackedStringArray:
	var i: int = path.rfind("/")
	if i == -1:
		return ["", path] 
	return [path.substr(0, i), path.substr(i + 1)]

func _get_folder(path: String) -> Folder:
	if path.is_empty():
		return root
		
	var current_folder: Folder = root
	for key: String in path.split("/", false):
		if current_folder.subfolders.has(key):
			current_folder = current_folder.subfolders[key]
			continue
		assert(false, "Error trying to get folder path '" + str(path) + "' missing: " + key)
		return null
		
	return current_folder
