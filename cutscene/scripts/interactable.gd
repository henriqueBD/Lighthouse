@icon("res://z_editor_only/interactable_icon.svg")
class_name Interactable
extends Area2D

enum pop_up_texture{
	UNASSIGNED,
	INVISIBLE,
	INFO,
	DIALOGUE,
	TRANSITION
}

signal interacted

const DIALOGUE_ICON_PATH: String = "res://assets/icon/dialogue_icon.png"
const TRANSITION_ICON_PATH: String = "res://assets/icon/transition_icon.png"

@export var pop_up_type: pop_up_texture
@export var active: bool = true

var _pop_up_image: Sprite2D
var _player_inside: bool

static func _static_init() -> void:
	assert(ResourceLoader.exists(DIALOGUE_ICON_PATH))
	assert(ResourceLoader.exists(TRANSITION_ICON_PATH))

func _ready() -> void:
	assert(pop_up_type != pop_up_texture.UNASSIGNED, "Assign popup at " + str(get_path()))
	if not active:
		GameManager.set_node_active(self, false)
	
	collision_mask = 2 ##TODO: MAKE THIS GLOBAL
	set_process_unhandled_input(false)
	
	GameManager.room_faded_in.connect(_on_room_fade_in, CONNECT_ONE_SHOT)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	if pop_up_type != pop_up_texture.INVISIBLE and pop_up_type != pop_up_texture.UNASSIGNED:
		_pop_up_image = Sprite2D.new()
		_pop_up_image.centered = false
		_pop_up_image.light_mask = 0
		_pop_up_image.hide()
		_pop_up_image.z_index = Global.pop_up_z_index
		
		var target_texture: Texture2D
		
		match pop_up_type:
			pop_up_texture.DIALOGUE:
				target_texture = load(DIALOGUE_ICON_PATH)
			pop_up_texture.TRANSITION:
				target_texture = load(TRANSITION_ICON_PATH)
		
		assert(target_texture)
		_pop_up_image.texture = target_texture
		add_child(_pop_up_image)
		
		assert(_pop_up_image,  "no image for interactable")
		
		@warning_ignore("integer_division")
		_pop_up_image.offset.x = -(_pop_up_image.texture.get_width() / 2)
		_pop_up_image.offset.y = -_pop_up_image.texture.get_height()

func _on_room_fade_in() -> void:
	monitoring = true

func _unhandled_input(event: InputEvent) -> void:
	if GameManager.is_player_locked(): return
	
	if event.is_action_pressed("Interact") and not GameManager.is_player_locked():
		if _pop_up_image:
			_pop_up_image.hide()
		GameManager.player_parent.turn_to_point(global_position)
		interacted.emit()

func _on_body_entered(_body: Node2D) -> void:
	if not active: return
	
	if _pop_up_image:
		_pop_up_image.global_position = global_position
		_pop_up_image.show()
	
	_player_inside = true
	set_process_unhandled_input(true)

func _on_body_exited(_body: Node2D) -> void:
	if pop_up_type != pop_up_texture.INVISIBLE:
		_pop_up_image.hide()
	
	_player_inside = false
	set_process_unhandled_input(false)
