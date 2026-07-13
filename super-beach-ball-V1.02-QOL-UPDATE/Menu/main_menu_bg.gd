extends Node3D
var rotate_ball_back = false
var first_rotation = false

func turn_ball_front():
	rotate_ball_back = false
	first_rotation = true

func turn_ball_back():
	rotate_ball_back = true
	first_rotation = true

func _physics_process(_delta: float) -> void:
	if first_rotation:
		if rotate_ball_back == false:
			$Ball.rotation.y = lerpf($Ball.rotation.y, -0.46, 0.1)
		else:
			$Ball.rotation.y = lerpf($Ball.rotation.y, 160, 0.1)
			
			
