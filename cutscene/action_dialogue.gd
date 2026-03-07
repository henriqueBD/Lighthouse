class_name TextBox
extends CutsceneAction

# TODO: Implement argument parsing
# TODO: Implement namespaces function,
#ex: shake_sceen(3) calls GameManager.call_global_method("", "heal", ["50"])
#ex: player.heal(50) calls GameManager.call_global_method("player", "heal", ["50"])

const DIALOGUE_SPEED_PER_CHAR: float = 0.1

@export var close_dialogue_box_on_end: bool
@export_multiline var dialogue: PackedStringArray

static var _regex: RegEx = init_regex()

var _count: int = 0
var _current_char_index: int
var _call_method_indexes: Dictionary[int, Array]
var _next_char_countdown: float
var _can_advance_dialogue: bool

static func init_regex() -> RegEx:
	var regex: RegEx = RegEx.new()
	regex.compile("\\{(.*?)\\}")
	return regex

func execute() -> void:
	_count = 0
	GameManager.main_node.show_dialogue_box(null)
	GameManager.main_node.change_dialogue_text(_parse_text(dialogue[0]))
	GameManager.toggle_listen_input(true)
	GameManager.interact_pressed.connect(_on_input_pressed)
	GameManager.set_process_func(_process)
	GameManager.is_playing_dialogue = true

func _next_char() -> void:
	if _call_method_indexes.has(_current_char_index):
		for parameters: Array in _call_method_indexes[_current_char_index]:
			GameManager.call_global_method(parameters[0], parameters[1], parameters[2])
	_current_char_index += 1

func _process(delta: float) -> void:
	_next_char_countdown -= delta
	
	if _next_char_countdown <= 0.0 and not _can_advance_dialogue:
		_next_char_countdown = DIALOGUE_SPEED_PER_CHAR
		_next_char()
		if GameManager.main_node.show_next_char():
			_can_advance_dialogue = true

func _on_input_pressed() -> void:
	if _can_advance_dialogue:
		_can_advance_dialogue = false
		_next_dialogue()

func _next_dialogue() -> void:
	_next_char()
	_count += 1
	if _count >= dialogue.size():
		GameManager.is_playing_dialogue = false
		GameManager.set_process_func(Callable())
		GameManager.toggle_listen_input(false)
		GameManager.interact_pressed.disconnect(_on_input_pressed)
		if close_dialogue_box_on_end:
			GameManager.main_node.hide_dialogue_box()
		action_ended.emit()
	else:
		_continue_dialogue()

func _continue_dialogue() -> void:
	GameManager.main_node.change_dialogue_text(_parse_text(dialogue[_count]))

func _parse_text(text: String) -> String:
	assert(not text.is_empty(), "Text should have content")
	
	var final_output: String = ""
	var cursor: int = 0
	_current_char_index = 0
	_call_method_indexes = {}
	
	var matches: Array[RegExMatch] = _regex.search_all(text)
	
	for regex_match: RegExMatch in matches:
		var start_index: int = regex_match.get_start()
		final_output += text.substr(cursor, start_index - cursor)
		
		var content: String = regex_match.get_string(1)
		
		var paren_start: int = content.find("(")
		var paren_end: int = content.rfind(")")
		
		# If we have valid parentheses, treat it as a function call
		if paren_start != -1 and paren_end != -1 and paren_end > paren_start:
			var call_path: String = content.substr(0, paren_start)
			var args_string: String = content.substr(paren_start + 1, paren_end - paren_start - 1)
			
			var name_space: String = ""
			var method_name: String = call_path
			
			# Extract namespace if a dot exists
			if "." in call_path:
				var parts: PackedStringArray = call_path.split(".", true, 1)
				name_space = parts[0]
				method_name = parts[1]
			
			var parsed_args: PackedStringArray = []
			if not args_string.strip_edges().is_empty():
				var raw_args: PackedStringArray = args_string.split(",")
				for arg: String in raw_args:
					parsed_args.append(arg.strip_edges())
			
			var current_idx: int = final_output.length()
			if not _call_method_indexes.has(current_idx):
				_call_method_indexes[current_idx] = []
			
			# Store a Dictionary with the execution details instead of just the name
			_call_method_indexes[current_idx].append([name_space, method_name, parsed_args])
			
		else:
			# If no parentheses, it's a variable replacement
			final_output += GameManager.get_string_var(content)
		
		cursor = regex_match.get_end()
	
	final_output += text.substr(cursor)
	return final_output

func _evaluate_function_call(content: String) -> String:
	return content.trim_suffix("()")
