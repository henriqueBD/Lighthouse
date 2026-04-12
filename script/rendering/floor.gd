class_name Floor
extends Sprite2D

var _unlit_clone: Sprite2D

func _ready() -> void:
	assert(get_children().size() == 0,)
	# 1. Turn this mask sprite into an invisible stencil window
	clip_children = CanvasItem.CLIP_CHILDREN_ONLY
	
	_unlit_clone = self.duplicate()
	
	#TODO: MAKE THIS GLOBAL
	_unlit_clone.light_mask = 8
	
	add_child(_unlit_clone)
