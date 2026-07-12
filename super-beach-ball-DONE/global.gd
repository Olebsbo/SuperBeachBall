extends Node

var tutorial = true
var tut_explanation_active = false
var initial_tutorial = false
var first_receive = false
var spiker_movement_testing = false
var first_spike = false
var first_enemy_spike = false
var enemy_spike_tut = false
var second_receive = false

var tree : Node
var ball : CharacterBody3D
var main : Node3D
var pvp = false

var blue_team_genders = 0 #0 is male spiker, female receiver. 1 is the genders flipped.
var red_team_genders = 0 #0 is male spiker, female receiver. 1 is the genders flipped.

var player_status = 0 #0 is receiver control, 1 is spiker control
var enemy_status = 0 #Same as player_status, but for enemy
var net_side = 0 #-1 is on player side, 1 is on enemy side
var last_hit_side = 0 #-1 is on player side, 1 on enemy side
var serving_side = -1 #-1 is on player side, 1 on enemy side
var winning_side = 0 #Same as the others
var ai_level = 1
var particles_on = true

var receive_pause = false
var spike_pause = false
var point_won = false
var updating_points = false
var served = false
var hit_out = false
var setup_complete = false
var menu_pause = false

var set_point_requirement = 10
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
		if tutorial == false:
			if blue_points >= set_point_requirement and blue_points - red_points >= 2:
				winning_side = -1
			elif red_points >= set_point_requirement and red_points - blue_points >= 2:
				winning_side = 1
		if main:
			main.transition_out()


func reset_field(current_scene_name : String):
	player_status = 0
	enemy_status = 0
	net_side = 0
	point_won = false
	updating_points = false
	served = false
	hit_out = false
	tree.change_scene(current_scene_name)
	setup_complete = false

func setup():
	if serving_side == -1:
		ball.global_position.x = -4.0
	else:
		ball.global_position.x = 4.0
	main.transition_in()
	setup_complete = true


func self_reset():
	tutorial = true
	tut_explanation_active = false
	initial_tutorial = false
	first_receive = false
	spiker_movement_testing = false
	first_spike = false
	first_enemy_spike = false
	enemy_spike_tut = false
	second_receive = false

	ball = null
	main = null
	pvp = false
	player_status = 0
	enemy_status = 0
	net_side = 0
	last_hit_side = 0
	serving_side = -1
	winning_side = 0
	receive_pause = false
	spike_pause = false
	point_won = false
	updating_points = false
	served = false
	hit_out = false
	
	setup_complete = false
	menu_pause = false
	blue_points = 0
	red_points = 0
