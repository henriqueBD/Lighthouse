@icon("res://z_editor_only/tracker_icon.svg")
class_name Tracker
extends Node

var _name: String

func _enter_tree() -> void:
	_name = get_parent().name
	GameManager.register_unique_entity(_name, self)

func _exit_tree() -> void:
	GameManager.unregister_unique_entity(_name)
