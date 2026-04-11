class_name ShadowCast
extends Sprite2D

@export var shadow_color: Color = Color(0.0, 0.0, 0.0, 0.4)
@export var shadow_length: float = 1.0
# For a 40 degree camera, the ground is squashed by roughly sin(40) ≈ 0.64
@export var perspective_squash: float = 0.64 

var _target_light: Node2D
var _shadow: Sprite2D
var _bottom_center_local: Vector2

func _ready() -> void:
	# 1. Account for Spritesheets
	var frame_size: Vector2 = texture.get_size() / Vector2(hframes, vframes)
	
	# 2. Safely find the local bottom center (accounts for whether parent is centered or has an offset)
	var center_x: float = 0.0 if centered else (frame_size.x / 2.0)
	var bottom_y: float = (frame_size.y / 2.0) if centered else frame_size.y
	_bottom_center_local = Vector2(center_x, bottom_y) + offset
	
	# Create the shadow child node
	_shadow = Sprite2D.new()
	_shadow.texture = texture
	_shadow.hframes = hframes
	_shadow.vframes = vframes
	_shadow.modulate = shadow_color
	_shadow.show_behind_parent = true
	
	_shadow.centered = false
	_shadow.offset = Vector2(-frame_size.x / 2.0, -frame_size.y)
	
	# Safely grab the light source
	var player: Node2D = GameManager.player.get_node_or_null("%Light")
	if player:
		_target_light = player
	else:
		push_warning("ShadowCast: Target light not found on player.")
	
	add_child(_shadow)

func _process(_delta: float) -> void:
	# Keep the shadow's visual state synced
	_shadow.frame = frame
	_shadow.flip_h = flip_h
	_shadow.flip_v = flip_v
	_shadow.visible = visible
	
	if _target_light:
		_calculate_dynamic_transform()

func _calculate_dynamic_transform() -> void:
	# 4. Get the exact global position of the sprite's base/feet
	var current_bottom_center: Vector2 = to_global(_bottom_center_local)
	
	# Get normalized direction to the light
	var dir_to_light: Vector2 = current_bottom_center.direction_to(_target_light.global_position)
	
	# Shadow casts away from the light
	var shadow_dir: Vector2 = -dir_to_light
	
	# 5. Build a sheer projection matrix (Transform2D)
	# The X axis stays flat to keep the base of the sprite horizontal.
	var x_axis: Vector2 = Vector2(global_scale.x, 0)
	
	# The Y axis determines where the "top" of the sprite points. 
	# Because Godot's local Y goes down, setting it to -shadow_dir perfectly pushes the head away.
	var y_axis: Vector2 = -shadow_dir * shadow_length * global_scale.y
	
	# Apply the 40-degree perspective squash to the Y coordinate of the projection
	y_axis.y *= perspective_squash
	
	# Apply the mathematically perfect projection matrix
	_shadow.global_transform = Transform2D(x_axis, y_axis, current_bottom_center)
