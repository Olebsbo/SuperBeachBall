extends AnimatedSprite3D


func _physics_process(_delta: float) -> void:
	if Global.net_side == -1:
		play("FlagWave")
	elif Global.net_side == 1:
		play("FlagWaveLeft")
