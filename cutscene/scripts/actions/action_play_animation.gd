##Plays a animation from a AnimatedSprite2D or a AnimationPlayer
class_name PlayAnimation
extends CutsceneAction

@export var source: NodePath
@export var animation_name: String
@export var wait_to_finish: bool

func execute(context: Node) -> void:
	var target_node: Node = context.get_node(source)
	if not target_node:
		assert(false, "Could not get node " + str(source))
		action_ended.emit()
		return
	
	assert(target_node is AnimatedSprite2D or target_node is AnimationPlayer)
	assert(_variant_has_animation(target_node),
	"No animation (" + animation_name + ") at " + str(source))
	
	if target_node is AnimationPlayer and target_node.has_animation(animation_name):
		target_node.play(animation_name)
		if wait_to_finish:
			await target_node.animation_finished
	elif target_node is AnimatedSprite2D and _sprite_2D_has_animation(target_node):
		target_node.play(animation_name)
		if wait_to_finish:
			await target_node.animation_finished
	
	action_ended.emit()

func _variant_has_animation(target_node: Node) -> bool:
	if target_node is AnimationPlayer:
		return target_node.has_animation(animation_name)
	elif target_node is AnimatedSprite2D:
		return _sprite_2D_has_animation(target_node)
	push_error("What in the actual fuck")
	return false

func _sprite_2D_has_animation(target_node: Node) -> bool:
	var frames: SpriteFrames = target_node.sprite_frames
	if not frames: return false
	return frames.has_animation(animation_name)
