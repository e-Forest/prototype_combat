extends CharacterBody2D

#const SPEED = 50.0
@onready var nav_agent = $NavAgent as NavigationAgent2D

var player:Player

func _ready():
	player = get_tree().get_nodes_in_group("player")[0]
	nav_agent.velocity_computed.connect(_on_velocity_computed)

func _physics_process(delta):
#	if nav_agent.is_target_reachable():
	var next_location = nav_agent.get_next_location()
	nav_agent.set_velocity(global_position.direction_to(next_location) * nav_agent.max_speed)
#	else:
#		nav_agent.set_velocity(Vector2.ZERO)


func _on_velocity_computed(safe_velocity):
	velocity = safe_velocity
	move_and_slide()


func _on_timer_timeout():
	nav_agent.set_target_location(player.global_position)
