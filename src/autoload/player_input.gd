extends Node

const  TRASHOLD:float = 5

signal aim_started
signal aim_ended(start_pos:Vector2,end_pos:Vector2)

var aim_start:Vector2
var aim_hold:Vector2
var aim_end:Vector2


func _process(delta):
	
	if Input.is_action_just_pressed("aim"):
		aim_start = get_viewport().get_mouse_position()
		emit_signal("aim_started")
	
	if Input.is_action_just_released("aim"):
		aim_end = get_viewport().get_mouse_position()
		emit_signal("aim_ended",aim_start,aim_end)
	
	if Input.is_action_pressed("aim"):
		aim_hold = get_viewport().get_mouse_position()
	else:
		aim_hold = aim_start


func get_dif_start2hold()->Vector2:
	var dif:Vector2 = aim_hold - aim_start
	if dif.length() > TRASHOLD:
		return (dif)
	else:
		return Vector2.ZERO


func get_dif_start2end()->Vector2:
	var dif:Vector2 = aim_end - aim_start
	if dif.length() > TRASHOLD:
		return (dif)
	else:
		return Vector2.ZERO


func get_move_vector()->Vector2:
	return Input.get_vector("west","east","north","south")
