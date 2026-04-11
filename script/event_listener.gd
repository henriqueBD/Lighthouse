class_name EventListener
extends Node

@export var event: GameVariable
@export var action: CutsceneAction

func _ready() -> void:
	assert(event, "No event set for " + str(get_path()))
	assert(action, "No action set for " + str(get_path()))
	
	if event and action:
		GameManager.subscribe_to_event(event, self)

func execute() -> void:
	if action:
		action.execute(get_parent())
