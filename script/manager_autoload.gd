extends Node

const DIALOGUE_SPEED_PER_CHAR: float = 0.1

enum global_variables_bool{
	STONE_SON_PICKED,
	TEST
}

var is_playing_dialogue: bool

var _main_node: ManagerMainNode

#dialogue related
var _current_dialogue: CutsceneActionDialogue
var _can_advance_dialogue: bool
var _next_char_countdown: float

var _global_variables_bool_map: Dictionary[global_variables_bool, bool]
var _global_variables_string_map: Dictionary[String, String]

var _global_methods_map: Dictionary[String, Callable] = {
	"test" : func() -> void: 
		print("Hello, world"),
	"test2" : func() -> void:
		print("Hello again")
}

#region Dialogue

func _ready() -> void:
	set_process_unhandled_input(false)
	set_process(false)

func start_dialogue(dialogue: CutsceneActionDialogue) -> void:
	_current_dialogue = dialogue
	is_playing_dialogue = true
	
	set_process_unhandled_input(true)
	set_process(true)
	
	var next_text: String = _current_dialogue.next_dialogue()
	
	print(next_text)
	
	_main_node.show_dialogue_box()
	_main_node.change_dialogue_text(next_text)

func _continue_dialogue() -> void:
	_can_advance_dialogue = false
	
	var next_text: String = _current_dialogue.next_dialogue()
	if next_text.is_empty():
		end_dialogue()
		return
	
	print(next_text)
	_main_node.change_dialogue_text(next_text)

func end_dialogue() -> void:
	set_process_unhandled_input(false)
	
	is_playing_dialogue = false
	print("dialogue ended")
	
	if _current_dialogue.close_dialogue_box_on_end:
		set_process(false)
		_main_node.hide_dialogue_box()
	
	_current_dialogue.action_ended.emit()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Interact") and _can_advance_dialogue:
		_continue_dialogue()

func _process(delta: float) -> void:
	_next_char_countdown -= delta
	
	if _next_char_countdown <= 0.0 and not _can_advance_dialogue:
		_next_char_countdown = DIALOGUE_SPEED_PER_CHAR
		_current_dialogue.next_char()
		if _main_node.show_next_char():
			_can_advance_dialogue = true

#endregion

func set_main_node(node_to_add: ManagerMainNode) -> void:
	assert(not _main_node, "main node set twice")
	_main_node = node_to_add

func get_string_var(key: String) -> String:
	return _global_variables_string_map.get(key, "")

func is_player_locked() -> bool:
	return is_playing_dialogue

func bool_is_active(key: global_variables_bool) -> bool:
	return _global_variables_bool_map.has(key)

func bool_set(key: global_variables_bool, value: bool) -> void:
	if value:
		assert(not _global_variables_bool_map.has(key), "Tried to add global bool twice")
		_global_variables_bool_map[key] = true
	else:
		if _global_variables_bool_map.has(key):
			_global_variables_bool_map.erase(key)
		else:
			assert(false, "Tried to erase a null global bool")

func call_global_method(method_name: String, arguments: Array) -> void:
	if _global_methods_map.has(method_name):
		_global_methods_map[method_name].call()
	else:
		assert(false, "no function with name " + method_name)
