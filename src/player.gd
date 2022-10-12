class_name Player extends CharacterBody2D

var move_dir:Vector2
var look_dir:Vector2

var attack_start_pos:Vector2
var attack_end_pos:Vector2
var attack_range:float = 50.0

var speed:float = 100.0


@onready var move_dir_pointer = $MoveDirPointer as Line2D
@onready var look_dir_pointer = $LookDirPointer as Line2D
@onready var aim_dir_pointer = $AimDirPointer as Line2D
@onready var state_machine = $StateMachine as StateMachine
@onready var animation_player = $AnimationPlayer as AnimationPlayer
@onready var attack_timer = $AttackTimer as Timer
@onready var debug_state = $DebugState as Label
@onready var attack_ray = $AttackRay  as RayCast2D


func _ready():
	PlayerInput.aim_ended.connect(self._on_aim_ended)
	state_machine.state_entered.connect(self._on_state_entered)
	attack_timer.timeout.connect(func(): state_machine.current_state = States.Player.idle)
	state_machine.current_state = States.Player.idle


func _process(delta):
	match state_machine.current_state:
		States.Player.idle:
			if PlayerInput.get_move_vector()!=Vector2.ZERO:
				state_machine.current_state = States.Player.run
			update_movement()
			update_aimpointer()
#			update_lookpointer(PlayerInput.get_move_vector())
		States.Player.run:
			update_movement()
			update_aimpointer()
			update_lookpointer(PlayerInput.get_move_vector())
			if PlayerInput.get_move_vector()==Vector2.ZERO:
				state_machine.current_state = States.Player.idle
#			print(str(PlayerInput.get_move_vector()))
		States.Player.attack:
			update_attack_movement()
			update_aimpointer()
			update_lookpointer(attack_end_pos-position)
			if is_move_in_aim_direction() and (attack_timer.time_left < attack_timer.wait_time/2):
				state_machine.current_state = States.Player.idle


func update_attack_movement():
	var a = attack_timer
	var timer_percent = a.time_left/a.wait_time
	if timer_percent < 0.5:
		var progress = timer_percent * 2
		position = attack_start_pos.lerp(attack_end_pos,progress)
	else:
		var progress = (timer_percent -0.5) *2
		position = attack_end_pos.lerp(attack_start_pos,progress)


func update_movement():
	var v2 = PlayerInput.get_move_vector()
	velocity = v2*speed
	move_dir_pointer.rotation = v2.angle()
	move_and_slide()


func update_lookpointer(local_pos:Vector2):
	if local_pos == Vector2.ZERO:
		return
	var dir = local_pos.normalized()
	look_dir_pointer.set_point_position(0,Vector2.ZERO)
	look_dir_pointer.set_point_position(1,dir*10)


func update_aimpointer():
	var target_pos = PlayerInput.get_delta_hold().normalized()*attack_range
	attack_ray.target_position = target_pos
	if attack_ray.is_colliding():
		target_pos = attack_ray.get_collision_point()-position
	aim_dir_pointer.set_point_position(0,Vector2.ZERO)
	aim_dir_pointer.set_point_position(1,target_pos)


func is_move_in_aim_direction()->bool:
	var ret = false
	if not PlayerInput.get_move_vector()==Vector2.ZERO:
		var aim_angle = PlayerInput.get_delta_end().angle()
		var move_input_angle = PlayerInput.get_move_vector().angle()
		var angle_delta = Helper.angle_dif(aim_angle, move_input_angle)
		ret = abs(angle_delta) < PI/3
	return ret


func _on_state_entered(state):
	debug_state.text = States.Player.keys()[state]
	match state:
		States.Player.idle:
			animation_player.play("idle")
		States.Player.run:
			animation_player.play("run")
		States.Player.attack:
			animation_player.play("attack")


func _on_aim_ended(start_pos:Vector2,end_pos:Vector2):
	state_machine.current_state = States.Player.attack
	attack_start_pos = position
	attack_end_pos = position + aim_dir_pointer.get_point_position(1)
	attack_timer.start()
