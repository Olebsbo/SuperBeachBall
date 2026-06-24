extends CharacterBody3D
@export var enemy_receiver : CharacterBody3D
@export var rest_location : Node3D
@export var speed = 10
var jump_height = 20
var spiking = false
var jumping = false
var spike_finish = false
var ball_height : float
var ball_time : float
var ball_x : float
var wait_time = 26
@onready var spike_area = $SpikeArea/CollisionShape3D

func _physics_process(_delta: float) -> void:
	if Global.point_won == false:
		if Global.receive_pause == false and Global.spike_pause == false:
			if spiking:
				#Waits before moving to spike so that ball is in right location
				if wait_time > 0:
					wait_time -= 1
				else:
					if global_position.x > ball_x:
						velocity.x = -speed
					else:
						velocity.x = 0
						if is_on_floor():
							if jumping:
								jumping = false
								spiking = false
								wait_time = 28
							else:
								velocity.y = jump_height
								$SpikeArea/CollisionShape3D.disabled = false
								jumping = true
					
			else:
				var distance = rest_location.global_position.x - global_position.x
				var direction = sign(distance)
				velocity.x = speed * direction
				if abs(distance) < 1:
					velocity.x = 0
			
			velocity.y -= 0.5
			animation()
			move_and_slide()
	else:
		$SpikeArea/CollisionShape3D.disabled = true
		velocity.y -= 0.5
		velocity.x = 0
		move_and_slide()
	animation()
			



func animation():
	if Global.enemy_status == 1:
		if jumping == true:
			if Global.spike_pause and Global.net_side == 1:
				$AnimationPlayer.play("Spike")
			elif velocity.y > -5 and is_on_floor():
				$AnimationPlayer.play("Jump")
			elif velocity.y <= 0 and not is_on_floor():
				$AnimationPlayer.play("Fall")
			else:
				return
		elif abs(velocity.x) > 2:
			$AnimationPlayer.play("Run")
		else:
			$AnimationPlayer.play("Idle")
	else:
		if Global.spike_pause and Global.net_side == 1:
			$AnimationPlayer.play("Spike")
		elif spike_finish and not is_on_floor():
			$AnimationPlayer.play("SpikeFinish")
		elif not is_on_floor():
			$AnimationPlayer.play("Fall")
		else:
			$AnimationPlayer.play("Idle")

func spike():
	spiking = true

func ball_data(i_height, i_vel, time, accel, x_spd, pos):
	ball_time = time * 0.85
	ball_height = i_height + i_vel * ball_time + 0.5 * accel * pow(time, 2)
	var dist = x_spd * ball_time
	var final_location = pos - dist
	ball_x = final_location


func successful_spike():
	if spike_finish == false:
		spike_area.disabled = true
		spike_finish = true
		$SpikeFinishTimer.start()
		Global.enemy_status = 0


func _on_spike_finish_timer_timeout() -> void:
	spike_finish = false
