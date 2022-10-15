class_name Player extends CharacterBody2D

signal  attack_ended

var body_height:int = 16

var move_dir:Vector2
var look_dir:Vector2

var attack_start_pos:Vector2
var attack_end_pos:Vector2
var attack_range:float = 50.0
#var attack_shorter_percent:float
var attack_time:float
var attack_time_default:float=0.4

var speed:float = 100.0


@onready var move_dir_pointer = $MoveDirPointer as Line2D
@onready var look_dir_pointer = $LookDirPointer as Line2D
@onready var aim_dir_pointer = $AimDirPointer as Line2D
@onready var state_machine = $StateMachine as StateMachine
@onready var animation_player = $AnimationPlayer as AnimationPlayer
@onready var debug_state = $DebugState as Label
@onready var attack_ray = $AttackRay  as RayCast2D
@onready var hit_box_stroke = $HitBoxStroke as HitBox
@onready var hit_box_stitch = $HitBoxStitch as HitBox
@onready var nav_agent = $NavAgent as NavigationAgent2D



func _ready():
	PlayerInput.aim_ended.connect(self._on_aim_ended)
	state_machine.state_entered.connect(self._on_state_entered)
	state_machine.current_state = States.Player.idle
	attack_ended.connect(func(): state_machine.current_state = States.Player.idle)


func _process(delta):
	match state_machine.current_state:
		States.Player.idle:
			if PlayerInput.get_move_vector()!=Vector2.ZERO:
				state_machine.current_state = States.Player.run
			update_movement()
			update_aimpointer()
		States.Player.run:
			update_movement()
			update_aimpointer()
			update_lookpointer(PlayerInput.get_move_vector())
			if PlayerInput.get_move_vector()==Vector2.ZERO:
				state_machine.current_state = States.Player.idle
		States.Player.attack:
			update_attack_movement(delta)
			update_aimpointer()
			update_lookpointer(get_attack_direction())
#			update_hitbox_stitch()
			if (is_move_in_aim_direction()
				and is_attack_halftime_reached()
				and is_position_walkable(global_position)):
				state_machine.current_state = States.Player.idle


func update_attack_movement(delta:float):
	attack_time-=delta
	if attack_time < 0.0:
		emit_signal("attack_ended")
		return
	var timer_percent = 1-attack_time/attack_time_default
	if not is_attack_halftime_reached():
		var progress = timer_percent * 2
		global_position = attack_start_pos.lerp(attack_end_pos,progress)
	else:
		var progress = (timer_percent -0.5) *2
		global_position = attack_end_pos.lerp(attack_start_pos,progress)


func update_movement():
	var v2 = PlayerInput.get_move_vector()
	set_velocity_consider_nav(v2)
	move_dir_pointer.rotation = v2.angle()
	move_and_slide()


func set_velocity_consider_nav(v2:Vector2):
	if v2 != Vector2.ZERO:
		nav_agent.set_target_location(global_position+v2*10)
		var next_location = nav_agent.get_next_location()
		velocity = global_position.direction_to(next_location) * speed
	else:
		velocity = Vector2.ZERO


func update_lookpointer(local_pos:Vector2):
	if local_pos == Vector2.ZERO:
		return
	var dir = local_pos.normalized()
	look_dir_pointer.set_point_position(0,Vector2.ZERO)
	look_dir_pointer.set_point_position(1,dir*10)


func update_aimpointer():
	var target_pos = PlayerInput.get_dif_start2hold().normalized()*attack_range
	attack_ray.target_position = target_pos
	if attack_ray.is_colliding():
		target_pos = attack_ray.get_collision_point()-position
	aim_dir_pointer.set_point_position(0,Vector2.ZERO)
	aim_dir_pointer.set_point_position(1,target_pos)


func get_attack_direction()->Vector2:
	return (attack_end_pos - attack_start_pos).normalized()


func is_move_in_aim_direction()->bool:
	var ret = false
	if not PlayerInput.get_move_vector()==Vector2.ZERO:
		var aim_angle = PlayerInput.get_dif_start2end().angle()
		var move_input_angle = PlayerInput.get_move_vector().angle()
		var angle_delta = Helper.angle_dif(aim_angle, move_input_angle)
		ret = abs(angle_delta) < PI/3
	return ret


func is_position_walkable(pos:Vector2)->bool:
	var old_target_pos = nav_agent.get_target_location()
	nav_agent.set_target_location(pos)
	var ret = nav_agent.is_target_reachable()
	nav_agent.set_target_location(old_target_pos)
	return ret


func is_attack_halftime_reached()->bool:
	return(attack_time < attack_time_default/2)


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
	attack_start_pos = position
	attack_end_pos = position + aim_dir_pointer.get_point_position(1)
	attack_time = attack_time_default
	state_machine.current_state = States.Player.attack
