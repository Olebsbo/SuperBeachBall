extends Control
@onready var play = $MainButtons/Play
@onready var options = $MainButtons/Options
@onready var exit = $MainButtons/Exit
@onready var options_panel: Panel = $OptionsPanel
@onready var main_buttons: Control = $MainButtons
var quit = false
var finished_anim = true
var turned_on = false

var hue = 0


func _ready():
	self.visible = false
	
	play.position = Vector2(-743, 317)
	options.position = Vector2(-763, 381)
	exit.position = Vector2(-783, 446)
	
	main_buttons.visible = true
	options_panel.visible = false
	quit = false
	finished_anim = false
	turned_on = false
	

func _physics_process(_delta: float) -> void:
	if turned_on:
		visible = true
		var hover_slide = 40
		hue += 0.003
		if hue > 1:
			hue = 0
		var color = Color.from_hsv(hue, 1, 0.9)
		if play.is_hovered():
			play.offset_transform_position.x = lerpf(play.offset_transform_position.x, hover_slide, 0.1)
			play.add_theme_color_override("font_hover_color", color)
		else:
			play.offset_transform_position.x = lerpf(play.offset_transform_position.x, 0, 0.1)
			play.add_theme_color_override("font_color", "black")
		
		if options.is_hovered():
			options.offset_transform_position.x = lerpf(options.offset_transform_position.x, hover_slide, 0.1)
			options.add_theme_color_override("font_hover_color", color)
		else:
			options.offset_transform_position.x = lerpf(options.offset_transform_position.x, 0, 0.1)
		
		
		if exit.is_hovered():
			exit.offset_transform_position.x = lerpf(exit.offset_transform_position.x, hover_slide, 0.1)
			exit.add_theme_color_override("font_hover_color", color)
		else:
			exit.offset_transform_position.x = lerpf(exit.offset_transform_position.x, 0, 0.1)
	else:
		visible = false

func turn_on():
	turned_on = true
	$AnimationPlayer.play("ButtonSlideIn")
	
func turn_off():
	turned_on = false

func _on_options_pressed() -> void:
	main_buttons.visible = false
	options_panel.visible = true


	
	
func _on_exit_pressed() -> void:
	if finished_anim:
		$AnimationPlayer.play("TransitionOut")
		quit = true
		finished_anim = false


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	finished_anim = true
	if anim_name == "TransitionOut":
		if quit:
			exit_game()
		

func exit_game():
	if quit:
		Global.main.continue_game()
		Global.self_reset()
		Global.tree.change_scene("res://Menu/main_menu.tscn")
	

func _on_back_options_pressed() -> void:
	main_buttons.visible = true
	options_panel.visible = false




func _on_play_pressed() -> void:
	if finished_anim:
		finished_anim = false
		Global.menu_pause = false
		Global.main.continue_game()
		turn_off()
