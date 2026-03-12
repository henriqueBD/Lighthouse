class_name TimeManager
extends Node

const SUNRISE_HOUR: float = 6.0
const SUNSET_HOUR: float = 18.0

## Gradient representing the 24-hour color cycle (0.0 is 0:00, 1.0 is 24:00)
@export var day_night_gradient: Gradient
@export var time_speed: float = 0.5

var _canvas_modulate: CanvasModulate
var _sun_light: DirectionalLight2D
var _current_time_hours: float = 8.00
var _target_time: float
var _custom_time_speed: float

func set_time(target: float) -> void:
	_current_time_hours = clamp(target, 0.0, 24.0)

func increment_time(time_delta: float) -> void:
	_current_time_hours = fposmod(_current_time_hours + time_delta, 24.0)

func set_time_smooth(target: float) -> void:
	_target_time = clamp(target, 0.0, 24.0)
	_start_process()

func increment_time_smooth(time_delta: float) -> void:
	if is_physics_processing():
		_target_time = fposmod(_target_time + time_delta, 24.0)
	else:
		_target_time = fposmod(_current_time_hours + time_delta, 24.0)
		set_physics_process(true)

func _ready() -> void:
	_canvas_modulate = $CanvasModulate
	_sun_light = $DirectionalLight2D
	assert(_canvas_modulate)
	assert(_sun_light)
	_sun_light.global_rotation = 0
	set_physics_process(false)
	_update_ambient_light()
	_update_sun()

func _physics_process(delta: float) -> void:
	_current_time_hours = move_toward(_current_time_hours, _target_time, delta * time_speed)
	if _current_time_hours == _target_time:
		set_physics_process(false)

func _start_process(custom_speed: float = _target_time) -> void:
	_custom_time_speed = custom_speed
	set_physics_process(true)

func _update_time() -> void:
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
	
	# Turn off the sun entirely at night to save performance
	_sun_light.enabled = is_daytime
	
	if is_daytime:
		_sun_light.global_rotation = remap(_current_time_hours, SUNRISE_HOUR, SUNSET_HOUR, PI / 2, - PI / 2)
		
		# Optional: Fade the sun's intensity at dawn and dusk for a smoother transition
		# Distance from noon (12.0). At noon distance is 0. At 6AM/6PM distance is 6.
		var distance_from_noon: float = abs(_current_time_hours - 12.0)
		
		# Map the distance (0 to 6) to energy (1.0 to 0.0)
		_sun_light.energy = remap(distance_from_noon, 0.0, 6.0, 1.5, 0.0)
