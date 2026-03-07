class_name TimeManager
extends Node

const SUNRISE_HOUR: float = 6.0
const SUNSET_HOUR: float = 18.0

## Gradient representing the 24-hour color cycle (0.0 is 0:00, 1.0 is 24:00)
@export var day_night_gradient: Gradient

# Time variables
@export var game_hours_per_real_second: float = 0.5

var _canvas_modulate: CanvasModulate
var _sun_light: DirectionalLight2D
var _current_time_hours: float = 15.5

func _ready() -> void:
	_canvas_modulate = $CanvasModulate
	assert(_canvas_modulate)
	_sun_light = $DirectionalLight2D
	assert(_sun_light)
	assert(_sun_light.global_rotation == 0)
	#set_physics_process(false)
	_update_ambient_light()
	_update_sun()

func _physics_process(delta: float) -> void:
	# Progress time
	_current_time_hours += delta * game_hours_per_real_second
	
	# Wrap time back to midnight after 24 hours
	if _current_time_hours >= 24.0:
		_current_time_hours -= 24.0
		
	_update_ambient_light()
	_update_sun()


func _update_ambient_light() -> void:
	if not _canvas_modulate: return
	# Convert 0-24 time into a 0.0 to 1.0 range to sample the gradient
	var time_percent: float = _current_time_hours / 24.0
	_canvas_modulate.color = day_night_gradient.sample(time_percent)
	return

func _update_sun() -> void:
	if not _sun_light: return
	
	var is_daytime: bool = _current_time_hours >= SUNRISE_HOUR and _current_time_hours <= SUNSET_HOUR
	#var is_daytime: bool = true
	
	# Turn off the sun entirely at night to save performance
	_sun_light.enabled = is_daytime
	
	if is_daytime:
		_sun_light.global_rotation = remap(_current_time_hours, SUNRISE_HOUR, SUNSET_HOUR, PI / 2, - PI / 2)
		
		# Optional: Fade the sun's intensity at dawn and dusk for a smoother transition
		# Distance from noon (12.0). At noon distance is 0. At 6AM/6PM distance is 6.
		var distance_from_noon: float = abs(_current_time_hours - 12.0)
		
		# Map the distance (0 to 6) to energy (1.0 to 0.0)
		_sun_light.energy = remap(distance_from_noon, 0.0, 6.0, 1.5, 0.0)
