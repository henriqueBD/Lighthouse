@icon("res://z_editor_only/marker_icon.svg")
class_name Marker
extends Marker2D

func _ready() -> void:
	assert(get_parent() is Place, "Markers must children of Place, is " + str(get_path()))

#Dont change name
func pull_object(object_name: String) -> void:
	var object: Node2D = GameManager.get_unique_entity_parent(object_name)
	if object:
		object.global_position = global_position
