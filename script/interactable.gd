@icon("res://z_editor_only/interactable_icon.svg")
class_name Interactable
extends Area2D

enum pop_up_texture{
	INVISIBLE,
	CUSTOM,
	DIALOGUE,
}

signal interacted

const DIALOGUE_ICON_PATH: String = "res://assets/icon/dialogue_icon.png"

@export var pop_up_type: pop_up_texture
@export var pop_up_image: Sprite2D
@export var active: bool = true

var _anchor_bottom_center: Node2D
var _player_inside: bool

func set_active(value: bool) -> void:
	active = value

func _ready() -> void:
	monitoring = false
	GameManager.room_faded_in.connect(_on_room_fade_in, CONNECT_ONE_SHOT)
	collision_mask = 2 ##TODO: MAKE THIS GLOBAL
	set_process_unhandled_input(false)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	if pop_up_type != pop_up_texture.INVISIBLE:
		for child: Node2D in get_children():
			if child is not CollisionShape2D:
				_anchor_bottom_center = child
				break
		
		if pop_up_type != pop_up_texture.CUSTOM:
			assert(not pop_up_image)
			pop_up_image = Sprite2D.new()
		
		pop_up_image.centered = false
		pop_up_image.light_mask = 0
		pop_up_image.hide()
		pop_up_image.z_index = 5 ##TODO: MAKE THIS GLOBAL
		
		match pop_up_type:
			pop_up_texture.CUSTOM:
				assert(pop_up_image, "no custom image")
			pop_up_texture.DIALOGUE:
				assert(ResourceLoader.exists(DIALOGUE_ICON_PATH))
				pop_up_image.texture = load(DIALOGUE_ICON_PATH)
		
		add_child(pop_up_image)
		
		assert(_anchor_bottom_center, "no anchor for interactable")
		assert(pop_up_image,  "no image for interactable")
		
		@warning_ignore("integer_division")
		pop_up_image.offset.x = -(pop_up_image.texture.get_width() / 2)
		pop_up_image.offset.y = -pop_up_image.texture.get_height()

func _on_room_fade_in() -> void:
	monitoring = true

func _unhandled_input(event: InputEvent) -> void:
	if GameManager.is_player_locked(): return
	
	if event.is_action_pressed("Interact") and not GameManager.is_player_locked():
		GameManager.player_parent.turn_to_point(global_position)
		interacted.emit()

func _on_body_entered(_body: Node2D) -> void:
	if not active: return
	
	if pop_up_type != pop_up_texture.INVISIBLE:
		pop_up_image.global_position = _anchor_bottom_center.global_position
		pop_up_image.show()
	
	_player_inside = true
	set_process_unhandled_input(true)

func _on_body_exited(_body: Node2D) -> void:
	if pop_up_type != pop_up_texture.INVISIBLE:
		pop_up_image.hide()
	
	_player_inside = false
	set_process_unhandled_input(false)
