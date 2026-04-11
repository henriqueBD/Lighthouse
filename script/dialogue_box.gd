class_name DialogueBox
extends Control
const _dialogue_SPEED_PER_CHAR: float = 0.04

signal dialogue_ended(close_dialogue_box: bool)

static var _regex: RegEx

var _raw_dialogue: PackedStringArray
var _close_on_end: bool = true
var _count: int = 0
var _current_char_index: int
var _call_method_indexes: Dictionary[int, Array]
var _next_char_countdown: float
var _can_advance_dialogue: bool
var _text: Label
var _portrait: TextureRect
var _character_portraits: Array[Texture2D]

static func _static_init() -> void:
	_regex = RegEx.new()
	_regex.compile("\\{(.*?)\\}")

func start_dialogue(raw_dialogue: PackedStringArray, close_on_end: bool) -> void:
	if not raw_dialogue:
		assert(false)
		_end_dialogue()
		return
	_can_advance_dialogue = false
	_raw_dialogue = raw_dialogue
	_close_on_end = close_on_end
	assert(_vibe_check_dialogue(), str(_raw_dialogue))
	_count = 0
	_text.visible_characters = 0
	_text.text = _parse_text(_raw_dialogue[0])
	set_process_unhandled_input(true)
	set_process(true)
	show()

func start_dialogue_character(portraits: Array[Texture2D]) -> void:
	if not _portrait:
		assert(false, "Tried to start character dialogue on a info box")
		get_tree().create_timer(0.3).timeout.connect(_end_dialogue, CONNECT_ONE_SHOT)
		return
	_character_portraits = portraits
	if not _character_portraits[0]:
		assert(false, "The first portrait should not be null")
		return
	_portrait.texture = _character_portraits[0]

func _ready() -> void:
	set_process(false)
	_text = %Label
	assert(_text)
	_portrait = get_node_or_null("%Portrait")

func _process(delta: float) -> void:
	_next_char_countdown -= delta
	
	if _next_char_countdown <= 0.0 and not _can_advance_dialogue:
		_next_char_countdown = _dialogue_SPEED_PER_CHAR
		_next_char()
		_text.visible_characters += 1
		if _text.visible_ratio == 1.0:
			_can_advance_dialogue = true

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Interact") and _can_advance_dialogue:
		_next_dialogue()

func _next_dialogue() -> void:
	_next_char()
	_count += 1
	if _count >= _raw_dialogue.size():
		#End dialogue
		_end_dialogue()
	else:
		_can_advance_dialogue = false
		_text.text = _parse_text(_raw_dialogue[_count])
		_text.visible_characters = 0
		if _portrait and _count < _character_portraits.size() and _character_portraits[_count]:
			_portrait.texture = _character_portraits[_count]

func _next_char() -> void:
	if _call_method_indexes.has(_current_char_index):
		for parameters: Array in _call_method_indexes[_current_char_index]:
			GameManager.call_global_method(parameters[0], parameters[1], parameters[2])
	_current_char_index += 1

func _parse_text(text: String) -> String:
	if text.is_empty():
		assert(false, "Text should have content")
		return ""
	
	text = tr(text)
	
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

func _end_dialogue() -> void:
	hide()
	set_process(false)
	set_process_unhandled_input(false)
	dialogue_ended.emit(_close_on_end)

func _vibe_check_dialogue() -> bool:
	for line: String in _raw_dialogue:
		if not line:
			push_error("NULL LINE")
			return false
		if line.is_empty():
			push_error("EMPTY LINE")
			return false
	return true
