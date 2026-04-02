class_name PullEntityToMarker
extends CutsceneAction

##Local or global
@export var entity_name: String
@export var marker_path: NodePath

func execute(context: Node) -> void:
	var marker: Marker = context.get_node(marker_path) as Marker
	if not marker:
		assert(false, "Could not get marker at " + str(marker_path))
		action_ended.emit()
		return
	
	marker.pull_object(entity_name)
	action_ended.emit()
