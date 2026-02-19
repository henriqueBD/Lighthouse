class_name CutsceneActionDialogue
extends CutsceneAction

@export var close_dialogue_box_on_end: bool
@export_multiline var dialogue: PackedStringArray

static var _regex: RegEx = init_regex()

var _count: int = 0
var _current_char_index: int
var _call_method_indexes: Dictionary[int, Array]

func execute() -> void:
	_count = 0
	_current_char_index = 0
	GameManager.start_dialogue(self)

static func init_regex() -> RegEx:
	var regex: RegEx = RegEx.new()
	regex.compile("\\{(.*?)\\}")
	return regex

func _parse_text(text: String) -> String:
	assert(not text.is_empty(), "Text should have content")
	
	var final_output: String = ""
	var cursor: int = 0
	_call_method_indexes = {}
	
	# Search original text
	var matches: Array[RegExMatch] = _regex.search_all(text)
	
	for regex_match: RegExMatch in matches:
		# 1. Append text existing BEFORE this tag
		var start_index: int = regex_match.get_start()
		final_output += text.substr(cursor, start_index - cursor)
		
		var content: String = regex_match.get_string(1)
		
		if content.ends_with("()"):
			var func_name: String = content.trim_suffix("()")
			
			# Register event at the CURRENT length of the final string
			var current_idx: int = final_output.length()
			if not _call_method_indexes.has(current_idx):
				_call_method_indexes[current_idx] = []
			_call_method_indexes[current_idx].append(func_name)
			# Function tags add nothing to final text
			
		else:
			# Variable replacement adds text
			final_output += GameManager.get_string_var(content)
		
		# 3. Move cursor to end of this match
		cursor = regex_match.get_end()
	
	# 4. Append any remaining text after the last tag
	final_output += text.substr(cursor)
	
	return final_output

func next_char() -> void:
	if _call_method_indexes.has(_current_char_index):
		for func_name: String in _call_method_indexes[_current_char_index]:
			GameManager.call_global_method(func_name, [])
	_current_char_index += 1

func next_dialogue() -> String:
	_count += 1
	if _count >= dialogue.size():
		return ""
	else:
		return _parse_text(dialogue[_count - 1])

func _evaluate_function_call(content: String) -> String:
	return content.trim_suffix("()")
