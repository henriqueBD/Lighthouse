##Conditional jump based if the cutscene played atleast once
class_name GotoPlayed
extends CutsceneAction

@export var jump_to_if_true: Cutscene #extends Resource

func execute() -> void:
	assert(false, "no")
	action_ended.emit()

func evaluate() -> Cutscene:
	var id: String = _get_unique_id()
	
	if GameManager.local_var_exists(id):
		return jump_to_if_true
	else:
		GameManager.set_local_var(id, null)
		return null

func _get_unique_id() -> String:
	const prime: int = 16777619
	assert(not jump_to_if_true.resource_path.is_empty())
	var text: String = jump_to_if_true.resource_path
	var hash_res: int = 2166136261
	# FNV prime (32-bit)
	var bytes: PackedByteArray = text.to_utf8_buffer()
	
	for b: int in bytes:
		hash_res = hash_res ^ b
		hash_res = (hash_res * prime) & 0xFFFFFFFF
	
	bytes.resize(4)
	bytes.encode_u32(0, hash_res)
	#TODO: Replaces the dangerous filename characters with safe ones
	#return Marshalls.raw_to_base64(bytes).trim_suffix("==").replace("/", "_").replace("+", "-")
	return Marshalls.raw_to_base64(bytes).trim_suffix("==")
