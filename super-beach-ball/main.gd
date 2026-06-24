extends Node3D
@export var ball : CharacterBody3D

func _ready() -> void:
	Global.ball = ball
	Global.main = self


func transition_in():
	$TransitionAnim.play("transitionIn")


func transition_out():
	$TransitionAnim.play("transitionOut")


func _on_transition_anim_animation_finished(anim_name: StringName) -> void:
	if anim_name == "transitionOut":
		Global.reset_field()
