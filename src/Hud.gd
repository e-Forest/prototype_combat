extends CanvasLayer

@onready var player_input_renderer = $PlayerInputRenderer as Line2D

func _process(delta):
	player_input_renderer.global_position = PlayerInput.aim_start
	player_input_renderer.set_point_position(0,Vector2.ZERO)
	player_input_renderer.set_point_position(1,PlayerInput.get_dif_start2hold())
