extends Node

const  TRASHOLD:float = 5

signal click_started
signal click_ended(start_pos:Vector2,end_pos:Vector2)


var _click_start:Vector2
var _click_hold:Vector2
var _click_end:Vector2


func _process(delta):
	
	if Input.is_action_just_pressed("aim"):
		_click_start = get_viewport().get_mouse_position()
		emit_signal("click_started")
	
	if Input.is_action_just_released("aim"):
		_click_end = get_viewport().get_mouse_position()
		emit_signal("click_ended",_click_start,_click_end)
	
	if Input.is_action_pressed("aim"):
		_click_hold = get_viewport().get_mouse_position()
	else:
		_click_hold = _click_start


func get_dif_start2hold()->Vector2:
	var dif:Vector2 = _click_hold - _click_start
	if dif.length() > TRASHOLD:
		return (dif)
	else:
		return Vector2.ZERO


func get_dif_start2end()->Vector2:
	var dif:Vector2 = _click_end - _click_start
	if dif.length() > TRASHOLD:
		return (dif)
	else:
		return Vector2.ZERO


func get_move_vector()->Vector2:
	return Input.get_vector("west","east","north","south")


func get_click_start()->Vector2:
	return _click_start
