extends Node3D
@export var pvp = false

@export var ball : CharacterBody3D
@onready var in_game_menu: Control = $PauseMenu/InGameMenu
@onready var player_win_animation: Sprite2D = $CanvasLayer/WinScreen/PlayerWinAnimation
@onready var enemy_win_animation: Sprite2D = $CanvasLayer/WinScreen/EnemyWinAnimation
@onready var transition: ColorRect = $CanvasLayer/Transition
@onready var win_screen: Node2D = $CanvasLayer/WinScreen
@onready var lose_animation: AnimatedSprite2D = $CanvasLayer/WinScreen/LosePanel/LoseAnimation
@onready var lose_panel: Panel = $CanvasLayer/WinScreen/LosePanel
@onready var effect_lines: ColorRect = $CanvasLayer/WinScreen/EffectLines
@onready var win_button: Button = $CanvasLayer/WinScreen/WinButton
@onready var wind_effects: GPUParticles3D = $WindEffects
@onready var leaf_effects: GPUParticles3D = $LeafEffects
var setup = false
var hue = 0
var win_to_exit_button = false



func _ready() -> void:
	if Global.particles_on:
		wind_effects.visible = true
		leaf_effects.visible = true
		wind_effects.amount = (Global.red_points + Global.blue_points + 1) * 2
		leaf_effects.amount = randi_range(wind_effects.amount, wind_effects.amount * 2)
	else:
		wind_effects.visible = false
		leaf_effects.visible = false
	
	Global.ball = ball
	Global.main = self
	Global.pvp = pvp
	Global.menu_pause = false
	get_tree().paused = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	player_win_animation.visible = false
	enemy_win_animation.visible = false
	transition.color = Color(0, 0, 0, 1)
	lose_panel.visible = false
	effect_lines.visible = false
	win_button.visible = false
	
	if Global.tutorial == false:
		$CanvasLayer/Score.visible = true
	
	var num_of_ships = randi_range(4, 8)
	for n in num_of_ships:
		var ship_load = load("res://objects/boat.tscn")
		var ship_object = ship_load.instantiate()
		add_child(ship_object)
		ship_object.global_position.z = randi_range(-600, -80)
		ship_object.global_position.x = randi_range(-350, 350)
		ship_object.global_position.y = -4.2
		ship_object.rotation_degrees.y = randi_range(-20, 20)
	
	var num_of_birds = randi_range(10, 15)
	var previous_bird_pos : Vector3 = Vector3(-100, -50, 40)
	var previous_bird_dir : int
	for n in num_of_birds:
		var flock = randi_range(1, 10)
		var bird_load = load("res://objects/bird.tscn")
		var bird = bird_load.instantiate()
		add_child(bird)
		if flock < 3:
			bird.global_position.z = randi_range(-200, -80)
			bird.global_position.x = randi_range(-250, 250)
			bird.global_position.y = randi_range(20, 60)
			bird.rotation_degrees.y = randi_range(-20, 20)
		else:
			bird.global_position.z = randf_range(previous_bird_pos.z - 5.0, previous_bird_pos.z + 5.0)
			bird.global_position.x = randf_range(previous_bird_pos.x - 5.0, previous_bird_pos.x + 5.0)
			bird.global_position.y = randf_range(previous_bird_pos.y - 1.0, previous_bird_pos.y + 1.0)
			bird.rotation_degrees.y = previous_bird_dir
		previous_bird_pos = Vector3(bird.global_position.x, bird.global_position.y, bird.global_position.z)
		previous_bird_dir = bird.rotation_degrees.y
	

func _physics_process(_delta: float) -> void:
	#Nature particle effects
	if Global.particles_on:
		var wind_material = wind_effects.process_material as ParticleProcessMaterial
		var leaf_material = leaf_effects.process_material as ParticleProcessMaterial
		if Global.net_side == -1:
			wind_material.direction = Vector3(1, 0, 0)
			leaf_material.direction = Vector3(1, 0, 0)
		else:
			wind_material.direction = Vector3(-1, 0, 0)
			leaf_material.direction = Vector3(-1, 0, 0)
		
	
	
	#Tutorial stuff
	if Global.tutorial and Global.first_receive == false and Global.initial_tutorial == false:
		$CanvasLayer/Score.visible = false
		Global.initial_tutorial = true
		Global.tut_explanation_active = true
		await get_tree().create_timer(0.3).timeout
		Global.tree.dialogue("res://Dialogue/InitialIntro.dialogue", "InitialIntro")
		get_tree().paused = true
	
	if Global.first_receive == false and Global.served == true and Global.tutorial and Global.tut_explanation_active == false:
		Global.tut_explanation_active = true
		Global.first_receive = true
		await get_tree().create_timer(0.3).timeout
		get_tree().paused = true
		await get_tree().create_timer(0.5).timeout
		var resource = load("res://Dialogue/ReceiveTutorial.dialogue")
		DialogueManager.show_dialogue_balloon(resource, "ReceiveTutorial")
	
	if Global.first_enemy_spike and Global.tutorial and Global.tut_explanation_active == false and Global.enemy_spike_tut == false:
		Global.tut_explanation_active = true
		Global.enemy_spike_tut = true
		await get_tree().create_timer(0.2).timeout
		get_tree().paused = true
		var resource = load("res://Dialogue/EnemySpikeTutorial.dialogue")
		DialogueManager.show_dialogue_balloon(resource, "EnemySpikeTutorial")
		
	
	if Global.first_receive == true and Global.first_enemy_spike and Global.receive_pause and Global.net_side == -1 and Global.served == true and Global.tutorial and Global.tut_explanation_active == false and Global.second_receive == false:
		Global.tut_explanation_active = true
		Global.second_receive = true
		await get_tree().create_timer(0.7).timeout
		get_tree().paused = true
		var resource = load("res://Dialogue/FinalTutorial.dialogue")
		DialogueManager.show_dialogue_balloon(resource, "FinalTutorial")
	
	
	
	
	#Ingame menu
	if Input.is_action_just_pressed("esc"):
		if Global.menu_pause:
			if Global.tut_explanation_active == false:
				get_tree().paused = false
			Global.menu_pause = false
			in_game_menu.turn_off()
		else:
			get_tree().paused = true
			Global.menu_pause = true
			in_game_menu.turn_on()
	hue += 0.003
	if hue > 1:
		hue = 0
	var color = Color.from_hsv(hue, 0.5, 1, 1)
	
	if win_to_exit_button:
		win_button.text = "EXIT"
		if win_button.is_hovered():
			win_button.scale = win_button.scale.lerp(Vector2(1.2, 1.2), 0.1)
			win_button.add_theme_color_override("font_hover_color", color)
		else:
			win_button.scale = win_button.scale.lerp(Vector2(1.05, 1.05), 0.1)
			win_button.add_theme_color_override("font_hover_color", "black")
	else:
		if win_button.is_hovered():
			win_button.scale = win_button.scale.lerp(Vector2(1.2, 1.2), 0.1)
			win_button.text = "EXIT"
			win_button.add_theme_color_override("font_hover_color", color)
		else:
			win_button.scale = win_button.scale.lerp(Vector2(1, 1), 0.1)
			win_button.text = "WIN"
			win_button.add_theme_color_override("font_hover_color", "black")
	
	


	
	

func continue_game():
	get_tree().paused = false
	Global.menu_pause = false



func transition_in():
	$TransitionAnim.play("transitionIn")
	if Global.tutorial == false:
		$CanvasLayer/Score.visible = true
		$CanvasLayer/Score.text = String("[bgcolor=red] " + str(Global.blue_points) + " : " + str(Global.red_points) + " [/bgcolor]")


func transition_out():
	if Global.winning_side != 0:
		transition.color = Color(0.9, 0.95, 0.95, 1)
	$TransitionAnim.play("transitionOut")


func _on_transition_anim_animation_finished(anim_name: StringName) -> void:
	if anim_name == "transitionOut":
		if in_game_menu.quit == true:
			in_game_menu.exit_game()
			return
		if Global.winning_side == 0:
			if Global.pvp == true:
				Global.reset_field("res://pvp_main.tscn")
			else:
				Global.reset_field("res://main.tscn")
		else:
			$CanvasLayer/WinScreen/ExitButtonTimer.start()
			if Global.winning_side == -1:
				player_win_animation.visible = true
				lose_animation.play("EnemyLose")
				var animation = randi_range(1, 5)
				if animation == 1 or animation == 2:
					$TransitionAnim.play("PlayerWinAnimation1")
				else:
					$TransitionAnim.play("PlayerWinAnimation2")
			elif Global.winning_side == 1:
				enemy_win_animation.visible = true
				lose_animation.play("PlayerLose")
				var animation = randi_range(1, 5)
				if animation == 1 or animation == 2:
					$TransitionAnim.play("EnemyWinAnimation1")
				else:
					$TransitionAnim.play("EnemyWinAnimation2")
	elif anim_name == "transitionIn":
		$CanvasLayer/Score.visible = false
	elif anim_name == "PlayerWinAnimation1" or anim_name == "PlayerWinAnimation2" or anim_name == "EnemyWinAnimation1" or anim_name == "EnemyWinAnimation2":
		pass


func _on_exit_pressed() -> void:
	continue_game()
	Global.self_reset()
	Global.tree.change_scene("res://Menu/main_menu.tscn")
	


func _on_exit_button_timer_timeout() -> void:
	win_to_exit_button = true
