class_name CutsceneActionDialogue
extends CutsceneAction

# TODO: Implement argument parsing
# TODO: Implement namespaces function,
#ex: shake_sceen(3) calls GameManager.call_global_method("", "heal", [50])
#ex: player.heal(50) calls GameManager.call_global_method("player", "heal", [50])

@export var close_dialogue_box_on_end: bool
@export_multiline var dialogue: PackedStringArray

static var _regex: RegEx = init_regex()

var _count: int = 0
var _current_char_index: int
var _call_method_indexes: Dictionary[int, Array]

func execute() -> void:
	_count = 0
	GameManager.start_dialogue(self)

static func init_regex() -> RegEx:
	var regex: RegEx = RegEx.new()
	regex.compile("\\{(.*?)\\}")
	return regex

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
			
			# Use Godot's built-in parser to convert the string CSV into a typed Array
			var parsed_args: Array = []
			if not args_string.strip_edges().is_empty():
				var evaluated_array: Variant = str_to_var("[ " + args_string + " ]")
				if evaluated_array is Array:
					parsed_args = evaluated_array
			
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

func next_char() -> void:
	if _call_method_indexes.has(_current_char_index):
		for parameters: Array in _call_method_indexes[_current_char_index]:
			GameManager.call_global_method(parameters[0], parameters[1], parameters[2])
	_current_char_index += 1

func next_dialogue() -> String:
	_count += 1
	if _count > dialogue.size():
		return ""
	else:
		return _parse_text(dialogue[_count - 1])

func _evaluate_function_call(content: String) -> String:
	return content.trim_suffix("()")
