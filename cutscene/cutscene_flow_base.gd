@abstract
class_name CutsceneFlow
extends Resource

@abstract func cursor_arrived() -> void
@abstract func should_advance() -> bool
@abstract func get_action_finish_signal() -> Signal
@abstract func execute_action() -> void
@abstract func get_next() -> CutsceneFlow
