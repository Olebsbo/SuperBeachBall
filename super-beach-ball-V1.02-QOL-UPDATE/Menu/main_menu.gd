extends CanvasLayer
@export var GUI : Control
@export var background : Node3D


func _ready() -> void:
	Global.point_won = false
	$AnimationPlayer.play("cameraAnim")
	GUI.mouse_on_title.connect(m_on_ttl)
	GUI.mouse_off_title.connect(m_off_ttl)
	

func m_on_ttl():
	background.turn_ball_back()

func m_off_ttl():
	background.turn_ball_front()

func _physics_process(_delta: float) -> void:
	Global.point_won = false
	Global.hit_out = false
	if $MusicPlayer.playing == false:
		$MusicPlayer.playing = true
