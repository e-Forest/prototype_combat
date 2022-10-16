class_name Player extends CharacterBody2D

signal  attack_ended

var body_height:int = 16

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
@onready var anim_sprite = $anim_sprite as AnimatedSprite2D
@onready var debug_state = $DebugState as Label
@onready var attack_ray = $AttackRay  as RayCast2D
@onready var hit_box_stroke = $HitBoxStroke as HitBox
@onready var hit_box_stitch = $HitBoxStitch as HitBox
@onready var nav_agent = $NavAgent as NavigationAgent2D
@onready var stitch_timer = $StitchTimer as ProTimer
@onready var stroke_timer = $StrokeTimer as ProTimer


func _ready():
	PlayerInput.aim_ended.connect(self._on_aim_ended)
	state_machine.state_entered.connect(self._on_state_entered)
	state_machine.current_state = States.Player.idle
	stitch_timer.timeout.connect(func(): state_machine.current_state = States.Player.idle)
	stroke_timer.timeout.connect(func(): state_machine.current_state = States.Player.idle)


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
		States.Player.attack_stroke:
			update_aimpointer()
			update_lookpointer(get_attack_direction())
		States.Player.attack_stitch:
			update_attack_movement(delta)
			update_aimpointer()
			update_lookpointer(get_attack_direction())
			if (is_move_in_aim_direction()
				and stitch_timer.get_percent()<0.5
				and is_position_walkable(global_position)):
				state_machine.current_state = States.Player.idle


func update_attack_movement(delta:float):
	var timer_percent = stitch_timer.get_percent()
	if timer_percent<0.5:
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
	anim_sprite.flip_h=abs(local_pos.angle())>PI/2


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


func _on_state_entered(state):
	debug_state.text = States.Player.keys()[state]
	match state:
		States.Player.idle:
			anim_sprite.play("idle")
		States.Player.run:
			anim_sprite.play("run")
		States.Player.attack_stroke:
			anim_sprite.play("attack_stroke")
		States.Player.attack_stitch:
			anim_sprite.play("attack_stitch")


func _on_aim_ended(start_pos:Vector2,end_pos:Vector2):
	attack_start_pos = position
	attack_end_pos = position + aim_dir_pointer.get_point_position(1)
	if PlayerInput.get_dif_start2end()==Vector2.ZERO:
		stroke_timer.start()
		state_machine.current_state = States.Player.attack_stroke
	else:
		stitch_timer.start()
		state_machine.current_state = States.Player.attack_stitch
