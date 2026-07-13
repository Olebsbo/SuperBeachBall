extends Node
var ball : CharacterBody3D
var main : Node3D

var player_status = 0 #0 is receiver control, 1 is spiker control
var enemy_status = 0 #Same as player_status, but for enemy
var net_side = 0 #-1 is on player side, 1 is on enemy side
var last_hit_side = 0 #-1 is on player side, 1 on enemy side
var serving_side = -1 #-1 is on player side, 1 on enemy side

var receive_pause = false
var spike_pause = false
var point_won = false
var updating_points = false
var served = false
var hit_out = false
var setup_complete = false


var blue_points = 0
var red_points = 0



func _physics_process(_delta: float) -> void:
	if setup_complete == false and ball and main:
		setup()
	
	if point_won and updating_points == false:
		updating_points = true
		if hit_out == false:
			if net_side == 1:
				blue_points += 1
				serving_side = -1
			elif net_side == -1:
				red_points += 1
				serving_side = 1
		else:
			if last_hit_side == -1:
				red_points += 1
				serving_side = 1
			elif last_hit_side == 1:
				blue_points += 1
				serving_side = -1
		receive_pause = false
		spike_pause = false
		await get_tree().create_timer(1.0).timeout
		main.transition_out()
		

func reset_field():
	print("b: ", blue_points, ", r:", red_points)
	player_status = 0
	enemy_status = 0
	net_side = 0
	point_won = false
	updating_points = false
	served = false
	hit_out = false
	get_tree().reload_current_scene()
	setup_complete = false

func setup():
	if serving_side == -1:
		pass
	else:
		ball.global_position.x = 5.4
	main.transition_in()
	setup_complete = true
	
	
