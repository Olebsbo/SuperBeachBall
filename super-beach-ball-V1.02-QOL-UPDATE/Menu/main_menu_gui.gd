extends Control
signal mouse_on_title
signal mouse_off_title

@onready var play = $MainButtons/Play
@onready var options = $MainButtons/Options
@onready var credits = $MainButtons/Credits
@onready var exit = $MainButtons/Exit
@onready var manual: Button = $MainButtons/Manual
@onready var PVEbutton = $PlayOptions/PlayerVsAI
@onready var PVPbutton = $PlayOptions/LocalPVP
@onready var TutorialButton: Button = $PlayOptions/Tutorial
@onready var options_panel: Panel = $OptionsPanel
@onready var credits_panel: Panel = $CreditsPanel
@onready var tutorial_manual: Panel = $TutorialManual
@onready var main_buttons: Control = $MainButtons
@onready var blue_team_gender_selector: CheckButton = $OptionsPanel/VBoxContainer/BlueTeamGenderSelector
@onready var red_team_gender_selector: CheckButton = $OptionsPanel/VBoxContainer/RedTeamGenderSelector
var start_vs_ai = false
var start_pvp = false
var quit = false
var finished_anim = true
var play_toggled = false

var hue = 0

func _ready():
	$AnimationPlayer.play("TransitionIn")
	finished_anim = false
	
	Global.tutorial = false
	
	play.position = Vector2(-743, 317)
	options.position = Vector2(-763, 381)
	credits.position = Vector2(-783, 446)
	exit.position = Vector2(-803, 513)
	manual.position = Vector2(-843, 635)
	PVEbutton.position = Vector2(-783, 446)
	PVPbutton.position = Vector2(-803, 513)
	TutorialButton.position = Vector2(-763, 381)
	
	
	tutorial_manual.visible = false
	main_buttons.visible = true
	credits_panel.visible = false
	options_panel.visible = false
	
	if Global.blue_team_genders == 1:
		blue_team_gender_selector.button_pressed = true
	if Global.red_team_genders == 1:
		red_team_gender_selector.button_pressed = true
	
	

func _physics_process(_delta: float) -> void:
	if $MenuMusic.playing == false:
		$MenuMusic.playing = true
	
	
	var hover_slide = 40
	hue += 0.003
	if hue > 1:
		hue = 0
	var color = Color.from_hsv(hue, 1, 0.9)
	if play.is_hovered():
		play.offset_transform_position.x = lerpf(play.offset_transform_position.x, hover_slide, 0.1)
		play.add_theme_color_override("font_hover_color", color)
	elif play_toggled:
		play.offset_transform_position.x = lerpf(play.offset_transform_position.x, hover_slide, 0.1)
		play.add_theme_color_override("font_color", color)
	else:
		play.offset_transform_position.x = lerpf(play.offset_transform_position.x, 0, 0.1)
		play.add_theme_color_override("font_color", "black")
	
	if options.is_hovered():
		options.offset_transform_position.x = lerpf(options.offset_transform_position.x, hover_slide, 0.1)
		options.add_theme_color_override("font_hover_color", color)
	else:
		options.offset_transform_position.x = lerpf(options.offset_transform_position.x, 0, 0.1)
	
	if credits.is_hovered():
		credits.offset_transform_position.x = lerpf(credits.offset_transform_position.x, hover_slide, 0.1)
		credits.add_theme_color_override("font_hover_color", color)
	else:
		credits.offset_transform_position.x = lerpf(credits.offset_transform_position.x, 0, 0.1)
		
	if exit.is_hovered():
		exit.offset_transform_position.x = lerpf(exit.offset_transform_position.x, hover_slide, 0.1)
		exit.add_theme_color_override("font_hover_color", color)
	else:
		exit.offset_transform_position.x = lerpf(exit.offset_transform_position.x, 0, 0.1)
	
	if manual.is_hovered():
		manual.offset_transform_position.x = lerpf(manual.offset_transform_position.x, hover_slide, 0.1)
		manual.add_theme_color_override("font_hover_color", color)
	else:
		manual.offset_transform_position.x = lerpf(manual.offset_transform_position.x, 0, 0.1)
	
	
	if PVEbutton.is_hovered():
		PVEbutton.offset_transform_position.x = lerpf(PVEbutton.offset_transform_position.x, hover_slide, 0.1)
		PVEbutton.add_theme_color_override("font_hover_color", color)
	else:
		PVEbutton.offset_transform_position.x = lerpf(PVEbutton.offset_transform_position.x, 0, 0.1)
		
	if PVPbutton.is_hovered():
		PVPbutton.offset_transform_position.x = lerpf(PVPbutton.offset_transform_position.x, hover_slide, 0.1)
		PVPbutton.add_theme_color_override("font_hover_color", color)
	else:
		PVPbutton.offset_transform_position.x = lerpf(PVPbutton.offset_transform_position.x, 0, 0.1)
	
	if TutorialButton.is_hovered():
		TutorialButton.offset_transform_position.x = lerpf(TutorialButton.offset_transform_position.x, hover_slide, 0.1)
		TutorialButton.add_theme_color_override("font_hover_color", color)
	else:
		TutorialButton.offset_transform_position.x = lerpf(TutorialButton.offset_transform_position.x, 0, 0.1)
	







	
	

func _on_options_pressed() -> void:
	main_buttons.visible = false
	options_panel.visible = true


func _on_credits_pressed() -> void:
	main_buttons.visible = false
	credits_panel.visible = true
	
	
func _on_exit_pressed() -> void:
	if finished_anim:
		$AnimationPlayer.play("TransitionOut")
		quit = true
		finished_anim = false


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	finished_anim = true
	if anim_name == "TransitionOut":
		if start_vs_ai:
			Global.tree.change_scene("res://main.tscn")
		elif start_pvp:
			Global.tree.change_scene("res://pvp_main.tscn")
		elif quit:
			get_tree().quit()
	elif anim_name == "TransitionIn":
		$AnimationPlayer.play("ButtonSlideIn")
		finished_anim = false


func _on_rich_text_label_mouse_entered() -> void:
	$Title.text = "[pulse][wave][tornado][rainbow]Super Beach Ball[/rainbow][/tornado][/wave][/pulse]"
	mouse_on_title.emit()

func _on_rich_text_label_mouse_exited() -> void:
	$Title.text =  "Super Beach Ball"
	mouse_off_title.emit()
	

func _on_back_options_pressed() -> void:
	main_buttons.visible = true
	options_panel.visible = false



func _on_back_credits_pressed() -> void:
	main_buttons.visible = true
	credits_panel.visible = false





func _on_player_vs_ai_pressed() -> void:
	if finished_anim:
		$AnimationPlayer.play("TransitionOut")
		start_vs_ai = true
		finished_anim = false


func _on_local_pvp_pressed() -> void:
	if finished_anim:
		$AnimationPlayer.play("TransitionOut")
		start_pvp = true
		finished_anim = false


func _on_play_pressed() -> void:
	if finished_anim:
		finished_anim = false
		if not play_toggled:
			play_toggled = true
			$AnimationPlayer.play("PlayOptionsSlideIn")
		else:
			play_toggled = false
			$AnimationPlayer.play("PlayOptionsSlideOut")


func _on_red_team_gender_selector_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Global.red_team_genders = 1
		red_team_gender_selector.text = "Red Team Genders: F Spiker, M Receiver"
	else:
		Global.red_team_genders = 0
		red_team_gender_selector.text = "Red Team Genders: M Spiker, F Receiver"


func _on_blue_team_gender_selector_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Global.blue_team_genders = 1
		blue_team_gender_selector.text = "Blue Team Genders: F Spiker, M Receiver"
	else:
		Global.blue_team_genders = 0
		blue_team_gender_selector.text = "Blue Team Genders: M Spiker, F Receiver"


func _on_tutorial_pressed() -> void:
	if finished_anim:
		Global.tutorial = true
		$AnimationPlayer.play("TransitionOut")
		start_vs_ai = true
		finished_anim = false


func _on_tutorial_manual_back_pressed() -> void:
	main_buttons.visible = true
	tutorial_manual.visible = false


func _on_manual_pressed() -> void:
	main_buttons.visible = false
	tutorial_manual.visible = true
