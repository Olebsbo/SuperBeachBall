extends Sprite3D
var timer_lock = false
var ball_pos_x : int = 0
var update_pos_x: int = 0

func _ready() -> void:
	self.visible = false


func land_zone_detected(pos):
	global_position = pos
	ball_pos_x = pos.x
	if timer_lock == false:
		$Timer.start()
		self.visible = true
		timer_lock = true

func land_zone_update(pos):
	update_pos_x = pos.x

func _on_timer_timeout() -> void:
	self.visible = false
	timer_lock = false
