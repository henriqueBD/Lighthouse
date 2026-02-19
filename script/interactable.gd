class_name Interactable
extends Area2D

enum pop_up_texture{
	INVISIBLE,
	DIALOGUE,
	CUSTOM
}

signal interacted

@export var pop_up_type: pop_up_texture

var _pop_up_image: Sprite2D
var _anchor_bottom_center: Node2D
var _player_inside: bool

func _ready() -> void:
	set_process_unhandled_input(false)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	if pop_up_type != pop_up_texture.INVISIBLE:
		for child: Node2D in get_children():
			if child is not CollisionShape2D:
				_anchor_bottom_center = child
				break
		
		_pop_up_image = Sprite2D.new()
		_pop_up_image.centered = false
		_pop_up_image.hide()
		
		match pop_up_type:
			pop_up_texture.DIALOGUE:
				_pop_up_image.texture = load("res://assets/icon/dialogue_icon.png") as Texture2D
		
		add_child(_pop_up_image)
		
		assert(_anchor_bottom_center, "no anchor for interactable")
		assert(_pop_up_image,  "no image for interactable")
		
		@warning_ignore("integer_division")
		_pop_up_image.offset.x = -(_pop_up_image.texture.get_width() / 2)
		_pop_up_image.offset.y = -_pop_up_image.texture.get_height()

func _unhandled_input(event: InputEvent) -> void:
	if GameManager.is_player_locked(): return
	
	if event.is_action_pressed("Interact"):
		print("Interacted")
		interacted.emit()

func _on_body_entered(_body: Node2D) -> void:
	if pop_up_type != pop_up_texture.INVISIBLE:
		_pop_up_image.global_position = _anchor_bottom_center.global_position
		_pop_up_image.show()
	
	_player_inside = true
	set_process_unhandled_input(true)

func _on_body_exited(_body: Node2D) -> void:
	if pop_up_type != pop_up_texture.INVISIBLE:
		_pop_up_image.hide()
	
	_player_inside = false
	set_process_unhandled_input(false)
