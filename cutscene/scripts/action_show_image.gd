class_name ShowImage
extends CutsceneAction

@export var image_to_show: Texture2D

var _can_continue: bool = true
var _texture_rect: TextureRect

func execute(_context: Node) -> void:
	assert(image_to_show)
	
	_texture_rect = TextureRect.new()
	GameManager.main_node.add_node_subviewport(_texture_rect)
	_texture_rect.set_anchors_preset(Control.PRESET_CENTER)
	_texture_rect.texture = image_to_show
	_texture_rect.size = image_to_show.get_size()
	_texture_rect.expand_mode = TextureRect.EXPAND_KEEP_SIZE
	
	GameManager.toggle_listen_input(true)
	GameManager.interact_pressed.connect(_on_interact_pressed)

func _on_interact_pressed() -> void:
	if _can_continue:
		GameManager.toggle_listen_input(false)
		GameManager.interact_pressed.disconnect(_on_interact_pressed)
		_texture_rect.queue_free()
		_texture_rect = null
		action_ended.emit()
