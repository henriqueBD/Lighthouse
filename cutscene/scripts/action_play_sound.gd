class_name PlaySound
extends CutsceneAction

@export var sound: AudioStream
@export var wait_to_finish: bool

func execute(_context: Node) -> void:
	if not sound:
		assert(false, "No sound to play")
		action_ended.emit()
		return
	
	if wait_to_finish:
		#Also implement GameManager.play_sound from the autoload
		await GameManager.play_sound(sound)
	else:
		GameManager.play_sound(sound)
	
	action_ended.emit()
