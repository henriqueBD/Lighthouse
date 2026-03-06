class_name ScreenTransition
extends CanvasLayer

@onready var _color_rect: ColorRect = %ColorRect

func fade_out() -> Signal:
	_color_rect.color = Color.from_rgba8(0,0,0,0)
	var fade_out_tween: Tween = create_tween()
	fade_out_tween.tween_property(_color_rect, "color", Color.BLACK, 0.25)
	return fade_out_tween.finished

func fade_in() -> Signal:
	_color_rect.color = Color.BLACK
	var fade_in_tween: Tween = create_tween()
	fade_in_tween.tween_property(_color_rect, "color", Color.from_rgba8(0,0,0,0), 0.25)
	return fade_in_tween.finished
