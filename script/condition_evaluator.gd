class_name ConditionEvaluator
extends Node

@export var actions: Array[ConditionRule]

func _ready() -> void:
	assert(actions, "Missing action for " + str(get_path()))
	assert(owner is Place)
	var place: Place = owner as Place
	if not place: return
	
	for action: ConditionRule in actions:
		assert(action)
		assert(_method_exists(action))
		#get var
		var target: Variant = place.get_var(action.target_var)
		if not target:
			continue
		
		#evaluate
		match action.operation:
			ConditionRule.Operation.EQUAL:
				if target == action.comparison_value:
					_call_action(action)
			ConditionRule.Operation.LESS:
				if target < action.comparison_value:
					_call_action(action)
			ConditionRule.Operation.GREATER:
				if target > action.comparison_value:
					_call_action(action)
			_:
				assert(false, "what")

func _call_action(action: ConditionRule) -> void:
	var target_method: Callable
	var target_node: Node = get_node(action.source)
	assert(target_node, "No such node " + str(action.source))
	if target_node and target_node.has_method(action.method_name):
		target_method = Callable(target_node, action.method_name)
	assert(target_method and target_method.is_valid())
	if not target_method.is_valid(): return
	if action.method_arguments:
		target_method.call(action.method_arguments)
	else:
		target_method.call()

func _method_exists(action: ConditionRule) -> bool:
	var target_method: Callable
	var target_node: Node = get_node(action.source)
	if target_node.has_method(action.method_name):
		target_method = Callable(target_node, action.method_name)
	return target_method and target_method.is_valid()
