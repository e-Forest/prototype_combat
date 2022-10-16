class_name StateMachine extends Node2D

signal state_entered(state:int)
signal state_exited(state:int)

var current_state:
	get:
		return current_state
	set(value):
		var old = current_state
		var new = value
		if old == new:
			return
		emit_signal("state_entered",new)
		emit_signal("state_exited",old)
		current_state = value
