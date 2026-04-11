@icon("res://z_editor_only/call_action.svg")
class_name ActionIfVarExists
extends Node

@export var to_check: GameVariable
@export var action_if_exists: CutsceneAction
@export var action_if_null: CutsceneAction
@export var apply_immediately: bool

func _ready() -> void:
	to_check.initialize()
	
	if owner is not Place:
		assert(false)
		return
	
	var owner_cast: Place = owner
	
	if owner_cast.var_exists(to_check):
		if action_if_exists:
			action_if_exists.execute(get_parent())
	else:
		if action_if_null:
			action_if_null.execute(get_parent())
	
	if apply_immediately:
		owner_cast.subscribe_to_var(to_check).connect(_call_action)

func _call_action() -> void:
	if action_if_exists:
		action_if_exists.execute(get_parent())
