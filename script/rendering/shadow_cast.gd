class_name ShadowCast
extends Sprite2D

const shadow_color: Color = Color(0.0, 0.0, 0.0, 0.4)

static var light_only_mat: Material = preload("res://light_only.tres")

# For a 40 degree camera, the ground is squashed by roughly sin(40) ≈ 0.64
@export var perspective_squash: float = 0.64 

var _target_light: Light2D
var _shadow: Sprite2D
var _pivot: Vector2

func _ready() -> void:
	
	# 1. Account for Spritesheets
	var frame_size: Vector2 = texture.get_size() / Vector2(hframes, vframes)
	
	# 2. Safely find the local bottom center (accounts for whether parent is centered or has an offset)
	var center_x: float = 0.0 if centered else (frame_size.x / 2.0)
	var bottom_y: float = (frame_size.y / 2.0) if centered else frame_size.y
	_pivot = to_global(Vector2(center_x, bottom_y) + offset)
	
	# Create the shadow child node
	_shadow = Sprite2D.new()
	_shadow.texture = texture
	_shadow.hframes = hframes
	_shadow.vframes = vframes
	_shadow.modulate = shadow_color
	_shadow.centered = false
	_shadow.offset = Vector2(-frame_size.x / 2.0, -frame_size.y)
	_shadow.material = light_only_mat
	_shadow.light_mask = Global.shadow_light_mask
	_shadow.z_as_relative = false
	_shadow.z_index = Global.shadow_z_index
	
	_target_light = GameManager.player.get_node_or_null("%Light")
	
	_on_lantern_toggle(GameManager.player.is_lantern_on())
	GameManager.player.lantern_toggle.connect(_on_lantern_toggle)
	
	add_child(_shadow)

func _process(_delta: float) -> void:
	
	#If the light too far, skip
	_target_light.get_height()
	
	# Keep the shadow's visual state synced
	#_shadow.frame = frame
	#_shadow.flip_h = flip_h
	#_shadow.flip_v = flip_v
	#_shadow.visible = visible
	
	if _target_light:
		_calculate_dynamic_transform()

func _calculate_dynamic_transform() -> void:
	# 4. Get the exact global position of the sprite's base/feet
	
	# Get normalized direction to the light
	var dir_to_light: Vector2 = _pivot.direction_to(_target_light.global_position)
	
	# Shadow casts away from the light
	var shadow_dir: Vector2 = -dir_to_light
	
	# 5. Build a sheer projection matrix (Transform2D)
	# The X axis stays flat to keep the base of the sprite horizontal.
	var x_axis: Vector2 = Vector2(global_scale.x, 0)
	
	# The Y axis determines where the "top" of the sprite points. 
	# Because Godot's local Y goes down, setting it to -shadow_dir perfectly pushes the head away.
	var y_axis: Vector2 = -shadow_dir * global_scale.y
	
	# Apply the 40-degree perspective squash to the Y coordinate of the projection
	y_axis.y *= perspective_squash
	
	# Apply the mathematically perfect projection matrix
	_shadow.global_transform = Transform2D(x_axis, y_axis, _pivot)

func _on_lantern_toggle(val: bool) -> void:
	_shadow.visible = val
	set_process(val)
