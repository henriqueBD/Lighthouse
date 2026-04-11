class_name PullEntityToMarker
extends CutsceneAction

##Local or global
@export var entity_name: String
@export var marker_name: String

func execute(_context: Node) -> void:
	var entity: Node2D = GameManager.get_unique_entity_parent(entity_name)
	var marker: Marker = GameManager.get_marker(marker_name)
	
	if marker and entity:
		entity.global_position = marker.global_position
	
	action_ended.emit()
